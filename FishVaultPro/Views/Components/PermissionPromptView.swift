import SwiftUI


struct PermissionPromptView: View {
    
    @EnvironmentObject var orchestrator: AppViewModel
    @State private var pulse = false
    
    var body: some View {
        GeometryReader { g in
            ZStack {
                Image(g.size.width > g.size.height ? "perm_dialog_bgl" : "perm_dialog_bg")
                    .resizable()
                    .scaledToFill()
                    .frame(width: g.size.width, height: g.size.height)
                    .ignoresSafeArea()
                
                if g.size.width > g.size.height {
                    horizontalContent
                } else {
                    verticalContent
                }
            }
        }
        .ignoresSafeArea()
    }
    
    private var iconArea: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.teal.opacity(0.3), Color.teal.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 150, height: 150)
                .scaleEffect(pulse ? 1.3 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 2.4).repeatForever(autoreverses: true),
                    value: pulse
                )
            
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 68))
                .foregroundColor(.teal)
        }
        .onAppear { pulse = true }
    }
    
    private var contentArea: some View {
        VStack(spacing: 22) {
            Text("Enable Updates")
                .font(.largeTitle.bold())
            
            Text("Stay informed about your fish vault activities and important notifications")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 58)
        }
    }
    
    private var verticalContent: some View {
        VStack(spacing: 12) {
            Spacer()
            
            Text("ALLOW NOTIFICATIONS ABOUT\nBONUSES AND PROMOS")
                .font(.custom("TitanOne", size: 20))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .multilineTextAlignment(.center)
            
            Text("STAY TUNED WITH BEST OFFERS FROM\nOUR CASINO")
                .font(.custom("TitanOne", size: 16))
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal, 12)
                .multilineTextAlignment(.center)
            
            actionsArea
        }
        .padding(.bottom, 24)
    }
    
    private var horizontalContent: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                VStack(alignment: .leading, spacing: 12) {
                    Text("ALLOW NOTIFICATIONS ABOUT\nBONUSES AND PROMOS")
                        .font(.custom("TitanOne", size: 20))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .multilineTextAlignment(.leading)
                    
                    Text("STAY TUNED WITH BEST OFFERS FROM OUR CASINO")
                        .font(.custom("TitanOne", size: 16))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal, 12)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                actionsArea
                Spacer()
            }
        }
        .padding(.bottom, 24)
    }
    
    private var actionsArea: some View {
        VStack(spacing: 20) {
            Button {
                orchestrator.grantPermission()
            } label: {
                Image("perm_dialog_accept")
                    .resizable()
                    .frame(width: 320, height: 60)
            }
            
            Button {
                orchestrator.denyPermission()
            } label: {
                Text("SKIP")
                    .font(.custom("TitanOne", size: 16))
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(width: 300, height: 35)
        }
        .padding(.horizontal, 48)
    }
}
