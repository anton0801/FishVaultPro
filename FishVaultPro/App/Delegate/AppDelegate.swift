import UIKit
import FirebaseCore
import FirebaseMessaging
import AppTrackingTransparency
import UserNotifications
import Combine
import AppsFlyerLib

final class LifecycleBridge: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    
    private let conversionBridge = ConversionBridge()
    private let notificationBridge = NotificationBridge()
    private let analyticsbridge = AnalyticsBridge()
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        setupFoundation()
        bridgeDelegates()
        activatePushServices()
        
        if let payload = launchOptions?[.remoteNotification] as? [AnyHashable: Any] {
            notificationBridge.route(payload)
        }
        
        analyticsbridge.configure(
            onConversionReceived: { [weak self] data in
                self?.conversionBridge.dispatchConversion(data)
            },
            onDeeplinkReceived: { [weak self] data in
                self?.conversionBridge.dispatchDeeplink(data)
            },
            onError: { [weak self] in
                self?.conversionBridge.dispatchConversion([:])
            }
        )
        
        observeAppLifecycle()
        
        return true
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // MARK: - Setup
    
    private func setupFoundation() {
        FirebaseApp.configure()
    }
    
    private func bridgeDelegates() {
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
    }
    
    private func activatePushServices() {
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    private func observeAppLifecycle() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationActivated),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    @objc private func applicationActivated() {
        analyticsbridge.initialize()
    }
    
    // MARK: - MessagingDelegate
    
    func messaging(
        _ messaging: Messaging,
        didReceiveRegistrationToken fcmToken: String?
    ) {
        messaging.token { token, error in
            guard error == nil, let token = token else { return }
            TokenVault.shared.persist(token)
        }
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        notificationBridge.route(notification.request.content.userInfo)
        completionHandler([.banner, .sound])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        notificationBridge.route(response.notification.request.content.userInfo)
        completionHandler()
    }
    
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        notificationBridge.route(userInfo)
        completionHandler(.newData)
    }
}

// MARK: - Conversion Bridge
final class ConversionBridge {
    
    private var conversionCache: [AnyHashable: Any] = [:]
    private var deeplinkCache: [AnyHashable: Any] = [:]
    private var mergeScheduler: Timer?
    private let dispatchedFlag = "trackingDataSent"
    
    func dispatchConversion(_ data: [AnyHashable: Any]) {
        conversionCache = data
        
        // FIXED: Короткий таймаут (2 секунды) для ожидания deeplink
        scheduleMerge()
        
        // Если deeplink уже есть - отправляем сразу
        if !deeplinkCache.isEmpty {
            merge()
        }
    }
    
    func dispatchDeeplink(_ data: [AnyHashable: Any]) {
        guard !wasDispatched() else { return }
        
        deeplinkCache = data
        
        // Публикуем deeplink отдельно
        broadcastDeeplink(data)
        
        cancelMerge()
        
        if !conversionCache.isEmpty {
            merge()
        }
    }
    
    // MARK: - Private Methods
    
    private func scheduleMerge() {
        mergeScheduler?.invalidate()
        
        // FIXED: 2 секунды вместо 10
        mergeScheduler = Timer.scheduledTimer(
            withTimeInterval: 4.0,
            repeats: false
        ) { [weak self] _ in
            self?.merge()
        }
    }
    
    private func cancelMerge() {
        mergeScheduler?.invalidate()
    }
    
    private func merge() {
        var merged = conversionCache
        
        deeplinkCache.forEach { key, value in
            if merged[key] == nil {
                merged[key] = value
            }
        }
        
        broadcastConversion(merged)
        markDispatched()
    }
    
    private func broadcastConversion(_ data: [AnyHashable: Any]) {
        NotificationCenter.default.post(
            name: Notification.Name("ConversionDataReceived"),
            object: nil,
            userInfo: ["conversionData": data]
        )
    }
    
    private func broadcastDeeplink(_ data: [AnyHashable: Any]) {
        NotificationCenter.default.post(
            name: Notification.Name("deeplink_values"),
            object: nil,
            userInfo: ["deeplinksData": data]
        )
    }
    
    private func wasDispatched() -> Bool {
        return UserDefaults.standard.bool(forKey: dispatchedFlag)
    }
    
    private func markDispatched() {
        UserDefaults.standard.set(true, forKey: dispatchedFlag)
    }
}

// MARK: - Analytics Bridge
final class AnalyticsBridge: NSObject {
    
    private var onConversionReceived: (([AnyHashable: Any]) -> Void)?
    private var onDeeplinkReceived: (([AnyHashable: Any]) -> Void)?
    private var onError: (() -> Void)?
    
    func configure(
        onConversionReceived: @escaping ([AnyHashable: Any]) -> Void,
        onDeeplinkReceived: @escaping ([AnyHashable: Any]) -> Void,
        onError: @escaping () -> Void
    ) {
        self.onConversionReceived = onConversionReceived
        self.onDeeplinkReceived = onDeeplinkReceived
        self.onError = onError
        
        setupSDK()
    }
    
    private func setupSDK() {
        let sdk = AppsFlyerLib.shared()
        sdk.appsFlyerDevKey = Config.appsFlyerKey
        sdk.appleAppID = Config.appsFlyerId
        sdk.delegate = self
        sdk.deepLinkDelegate = self
    }
    
    func initialize() {
        if #available(iOS 14.0, *) {
            AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)
            
            ATTrackingManager.requestTrackingAuthorization { _ in
                DispatchQueue.main.async {
                    AppsFlyerLib.shared().start()
                }
            }
        } else {
            AppsFlyerLib.shared().start()
        }
    }
}

// MARK: - AppsFlyerLibDelegate
extension AnalyticsBridge: AppsFlyerLibDelegate {
    
    func onConversionDataSuccess(_ data: [AnyHashable: Any]) {
        onConversionReceived?(data)
    }
    
    func onConversionDataFail(_ error: Error) {
        onError?()
    }
}

// MARK: - DeepLinkDelegate
extension AnalyticsBridge: DeepLinkDelegate {
    
    func didResolveDeepLink(_ result: DeepLinkResult) {
        guard case .found = result.status,
              let link = result.deepLink else {
            return
        }
        
        onDeeplinkReceived?(link.clickEvent)
    }
}

// MARK: - Notification Bridge
final class NotificationBridge {
    
    func route(_ payload: [AnyHashable: Any]) {
        guard let destination = parse(payload) else {
            return
        }
        
        UserDefaults.standard.set(destination, forKey: "temp_url")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            NotificationCenter.default.post(
                name: Notification.Name("LoadTempURL"),
                object: nil,
                userInfo: ["temp_url": destination]
            )
        }
    }
    
    private func parse(_ payload: [AnyHashable: Any]) -> String? {
        // Direct
        if let url = payload["url"] as? String {
            return url
        }
        
        // Nested
        if let data = payload["data"] as? [String: Any],
           let url = data["url"] as? String {
            return url
        }
        
        return nil
    }
}

// MARK: - Token Vault
final class TokenVault {
    
    static let shared = TokenVault()
    
    private init() {}
    
    func persist(_ token: String) {
        let storage = UserDefaults.standard
        storage.set(token, forKey: "fcm_token")
        storage.set(token, forKey: "push_token")
    }
    
    func retrieve() -> String? {
        return UserDefaults.standard.string(forKey: "push_token")
    }
}
