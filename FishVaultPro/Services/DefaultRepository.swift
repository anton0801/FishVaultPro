import Foundation
import AppsFlyerLib
import Firebase
import FirebaseMessaging

protocol StorageServiceProtocol {
    func saveAttribution(_ data: [String: Any])
    func loadAttribution() -> [String: Any]
    func saveDeeplink(_ data: [String: Any])
    func loadDeeplink() -> [String: Any]
    func saveURL(_ url: String)
    func loadURL() -> String?
    func saveMode(_ mode: String)
    func loadMode() -> String?
    func saveFirstLaunch(_ value: Bool)
    func isFirstLaunch() -> Bool
    func savePermissionGranted(_ value: Bool)
    func isPermissionGranted() -> Bool
    func savePermissionDenied(_ value: Bool)
    func isPermissionDenied() -> Bool
    func saveLastPermissionRequest(_ date: Date)
    func loadLastPermissionRequest() -> Date?
}

final class StorageService: StorageServiceProtocol {
    
    private let defaults = UserDefaults.standard
    private var attributionCache: [String: Any] = [:]
    private var deeplinkCache: [String: Any] = [:]
    
    func saveAttribution(_ data: [String: Any]) {
        attributionCache = data
    }
    
    func loadAttribution() -> [String: Any] {
        return attributionCache
    }
    
    func saveDeeplink(_ data: [String: Any]) {
        deeplinkCache = data
    }
    
    func loadDeeplink() -> [String: Any] {
        return deeplinkCache
    }
    
    func saveURL(_ url: String) {
        defaults.set(url, forKey: "cached_endpoint")
    }
    
    func loadURL() -> String? {
        return defaults.string(forKey: "cached_endpoint")
    }
    
    func saveMode(_ mode: String) {
        defaults.set(mode, forKey: "app_status")
    }
    
    func loadMode() -> String? {
        return defaults.string(forKey: "app_status")
    }
    
    func saveFirstLaunch(_ value: Bool) {
        defaults.set(value, forKey: "launchedBefore")
    }
    
    func isFirstLaunch() -> Bool {
        return !defaults.bool(forKey: "launchedBefore")
    }
    
    func savePermissionGranted(_ value: Bool) {
        defaults.set(value, forKey: "permissions_accepted")
    }
    
    func isPermissionGranted() -> Bool {
        return defaults.bool(forKey: "permissions_accepted")
    }
    
    func savePermissionDenied(_ value: Bool) {
        defaults.set(value, forKey: "permissions_denied")
    }
    
    func isPermissionDenied() -> Bool {
        return defaults.bool(forKey: "permissions_denied")
    }
    
    func saveLastPermissionRequest(_ date: Date) {
        defaults.set(date, forKey: "permission_request_time")
    }
    
    func loadLastPermissionRequest() -> Date? {
        return defaults.object(forKey: "permission_request_time") as? Date
    }
}
