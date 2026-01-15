// Views/Splash/SplashView.swift
import SwiftUI

struct SplashView: View {
    @State private var scale: CGFloat = 0.95
    @State private var opacity: Double = 0
    @State private var particlesOpacity: Double = 0
    @Binding var isActive: Bool
    
    var body: some View {
        ZStack {
            AppColors.deepOcean.ignoresSafeArea()
            
            // Particle effects
            ForEach(0..<20, id: \.self) { index in
                BubbleParticle(delay: Double(index) * 0.1)
                    .opacity(particlesOpacity)
            }
            
            VStack(spacing: 30) {
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
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
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
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeOut(duration: 0.5)) {
                    isActive = false
                }
            }
        }
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
