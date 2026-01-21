import Foundation
import Firebase
import FirebaseMessaging
import WebKit
import AppsFlyerLib

struct Config {
    static let appsFlyerKey = "b9VgeRjnUBAF3k4vrqdRsF"
    static let appsFlyerId = "6757870142"
}

protocol ValidationServiceProtocol {
    func validate() async throws -> Bool
}

protocol NetworkServiceProtocol {
    func fetchAttribution(deviceID: String) async throws -> [String: Any]
    func fetchURL(attribution: [String: Any]) async throws -> String
}

final class NetworkService: NetworkServiceProtocol {
    
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetchAttribution(deviceID: String) async throws -> [String: Any] {
        let urlString = "https://gcdsdk.appsflyer.com/install_data/v4.0/id\(Config.appsFlyerId)?devkey=\(Config.appsFlyerKey)&device_id=\(deviceID)"
        
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        let request = URLRequest(url: url, timeoutInterval: 30)
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NetworkError.invalidResponse
        }
        
        return json
    }
    
    private var user: String = WKWebView().value(forKey: "userAgent") as? String ?? ""
    
    func fetchURL(attribution: [String: Any]) async throws -> String {
        guard let url = URL(string: "https://fiishvaultpro.com/config.php") else {
            throw NetworkError.invalidURL
        }
        
        var payload = attribution
        payload["os"] = "iOS"
        payload["af_id"] = AppsFlyerLib.shared().getAppsFlyerUID()
        payload["bundle_id"] = Bundle.main.bundleIdentifier ?? "com.proappsfish.FishVaultPro"
        payload["firebase_project_id"] = FirebaseApp.app()?.options.gcmSenderID
        payload["store_id"] = "id\(Config.appsFlyerId)"
        payload["push_token"] = UserDefaults.standard.string(forKey: "push_token") ?? Messaging.messaging().fcmToken
        payload["locale"] = Locale.preferredLanguages.first?.prefix(2).uppercased() ?? "EN"
        
        var request = URLRequest(url: url, timeoutInterval: 30)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(user, forHTTPHeaderField: "User-Agent")
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        let (data, _) = try await session.data(for: request)
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let success = json["ok"] as? Bool,
              success,
              let resultURL = json["url"] as? String else {
            throw NetworkError.invalidResponse
        }
        
        return resultURL
    }
}

enum NetworkError: Error {
    case invalidURL
    case serverError
    case invalidResponse
}
