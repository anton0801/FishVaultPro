
import SwiftUI
import Combine

struct SplashView: View {
    @State private var scale: CGFloat = 0.95
    @State private var opacity: Double = 0
    @State private var particlesOpacity: Double = 0
    
    var body: some View {
        GeometryReader { g in
            ZStack {
                AppColors.deepOcean.ignoresSafeArea()
                
                Image(g.size.width > g.size.height ? "load_screen_bgl" : "load_screen_bg")
                    .resizable()
                    .scaledToFill()
                    .frame(width: g.size.width, height: g.size.height)
                    .ignoresSafeArea()
                
                // Particle effects
                ForEach(0..<20, id: \.self) { index in
                    BubbleParticle(delay: Double(index) * 0.1)
                        .opacity(particlesOpacity)
                }
                
                VStack(spacing: 12) {
                    // Fish icon in circle
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        AppColors.primaryAccent.opacity(0.3),
                                        AppColors.primaryAccent.opacity(0.1)
                                    ],
                                    center: .center,
                                    startRadius: 50,
                                    endRadius: 100
                                )
                            )
                            .frame(width: 200, height: 200)
                            .blur(radius: 20)
                        
                        Circle()
                            .stroke(AppColors.primaryAccent.opacity(0.3), lineWidth: 2)
                            .frame(width: 150, height: 150)
                        
                        FishIcon()
                            .frame(width: 80, height: 80)
                            .foregroundColor(AppColors.primaryAccent)
                    }
                    .scaleEffect(scale)
                    
                    // App name
                    Text(AppConstants.appName)
                        .font(.custom("TitanOne", size: 24))
                        .foregroundColor(AppColors.textPrimary)
                        .opacity(opacity)
                    
                    Text("Loading...")
                        .font(.custom("TitanOne", size: 32))
                        .foregroundColor(AppColors.textPrimary)
                        .opacity(opacity)
                    
                    Text("Wait until all data loads...")
                        .font(.custom("TitanOne", size: 12))
                        .foregroundColor(AppColors.textPrimary.opacity(0.7))
                        .opacity(opacity)
                }
            }
            .onAppear {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                    scale = 1.0
                    opacity = 1.0
                }
                
                withAnimation(.easeIn(duration: 1.0).delay(0.3)) {
                    particlesOpacity = 1.0
                }
            
            }
        }
        .ignoresSafeArea()
    }
}

struct FishIcon: View {
    var body: some View {
        Image(systemName: "drop.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}

struct BubbleParticle: View {
    let delay: Double
    @State private var yOffset: CGFloat = 0
    @State private var xOffset: CGFloat = 0
    
    var body: some View {
        Circle()
            .fill(AppColors.primaryAccent.opacity(0.2))
            .frame(width: CGFloat.random(in: 4...12), height: CGFloat.random(in: 4...12))
            .position(
                x: CGFloat.random(in: 50...UIScreen.main.bounds.width - 50),
                y: UIScreen.main.bounds.height + yOffset
            )
            .onAppear {
                withAnimation(
                    Animation.linear(duration: Double.random(in: 3...6))
                        .repeatForever(autoreverses: false)
                        .delay(delay)
                ) {
                    yOffset = -UIScreen.main.bounds.height - 100
                }
                
                withAnimation(
                    Animation.easeInOut(duration: 2)
                        .repeatForever(autoreverses: true)
                        .delay(delay)
                ) {
                    xOffset = CGFloat.random(in: -20...20)
                }
            }
    }
}

struct VaultApplicationView: View {
    
    @StateObject private var orchestrator = AppViewModel()
    @State private var observers: Set<AnyCancellable> = []
    
    var body: some View {
        ZStack {
            mainContent
            
            if orchestrator.showPermissionPrompt {
                PermissionPromptView()
                    .environmentObject(orchestrator)
                    .transition(.opacity.combined(with: .scale))
            }
        }
        .onAppear {
            setupEventObservers()
        }
    }
    
    @ViewBuilder
    private var mainContent: some View {
        switch orchestrator.state {
        case .idle, .loading, .validating, .validated:
            SplashView()
            
        case .active:
            if orchestrator.targetURL != nil {
                VaultContentView()
            } else {
                MainView()
            }
            
        case .inactive:
            MainView()
            
        case .offline:
            DisconnectedView()
        }
    }
    
    private func setupEventObservers() {
        NotificationCenter.default
            .publisher(for: Notification.Name("ConversionDataReceived"))
            .compactMap { $0.userInfo?["conversionData"] as? [String: Any] }
            .sink { data in
                orchestrator.handleAttribution(data)
            }
            .store(in: &observers)
        
        NotificationCenter.default
            .publisher(for: Notification.Name("deeplink_values"))
            .compactMap { $0.userInfo?["deeplinksData"] as? [String: Any] }
            .sink { data in
                orchestrator.handleDeeplink(data)
            }
            .store(in: &observers)
    }
}


#Preview {
    SplashView()
}
