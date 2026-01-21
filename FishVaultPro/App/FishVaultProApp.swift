import SwiftUI
import Firebase

@main
struct FishVaultProApp: App {
    
    @UIApplicationDelegateAdaptor(LifecycleBridge.self) var d
    
    var body: some Scene {
        WindowGroup {
            VaultApplicationView()
        }
    }
}

struct MainView: View {
    
    @StateObject private var authService = AuthService.shared
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    
    var body: some View {
        ZStack {
            if showOnboarding {
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
