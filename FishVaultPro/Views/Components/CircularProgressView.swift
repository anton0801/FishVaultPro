// Views/Components/CircularProgressView.swift
import SwiftUI
import WebKit

struct CircularProgressView: View {
    let progress: Double
    let size: CGFloat
    
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(AppColors.textSecondary.opacity(0.2), lineWidth: 12)
                .frame(width: size, height: size)
            
            // Progress circle
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    LinearGradient(
                        colors: [AppColors.progressColor, AppColors.secondaryAccent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
            
            // Percentage text
            VStack(spacing: 4) {
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Text("Complete")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.7)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { newValue in
            withAnimation(.spring(response: 0.6)) {
                animatedProgress = newValue
            }
        }
    }
}

final class CookieDecorator {
    
    private let storageKey = "stored_sessions"
    
    func restore() {
        guard let storage = UserDefaults.standard.object(forKey: storageKey) as? [String: [String: [HTTPCookiePropertyKey: AnyObject]]] else {
            return
        }
        
        let cookieStore = WKWebsiteDataStore.default().httpCookieStore
        
        let cookies = storage.values
            .flatMap { $0.values }
            .compactMap { properties in
                HTTPCookie(properties: properties as [HTTPCookiePropertyKey: Any])
            }
        
        cookies.forEach { cookie in
            cookieStore.setCookie(cookie)
        }
    }
    
    func capture(from view: WKWebView) {
        let cookieStore = view.configuration.websiteDataStore.httpCookieStore
        
        cookieStore.getAllCookies { [weak self] cookies in
            guard let self = self else { return }
            
            var storage: [String: [String: [HTTPCookiePropertyKey: Any]]] = [:]
            
            for cookie in cookies {
                var domainCookies = storage[cookie.domain] ?? [:]
                
                if let properties = cookie.properties {
                    domainCookies[cookie.name] = properties
                }
                
                storage[cookie.domain] = domainCookies
            }
            
            UserDefaults.standard.set(storage, forKey: self.storageKey)
        }
    }
}
