import SwiftUI
import Firebase

@main
struct FishVaultProApp: App {
    @StateObject private var authService = AuthService.shared
    @State private var showSplash = true
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashView(isActive: $showSplash)
                    
                } else if showOnboarding {
                    OnboardingView(showOnboarding: $showOnboarding)
                        .onDisappear {
                            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                        }
                } else {
                    VaultListView()
                        .preferredColorScheme(.dark)
                }
            }
        }
    }
}
