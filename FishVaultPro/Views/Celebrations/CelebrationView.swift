
import SwiftUI

struct CelebrationView: View {
    let milestone: Milestone
    let newFish: FishType?
    @Binding var isPresented: Bool
    
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var confettiOpacity: Double = 0
    
    var body: some View {
        ZStack {
            // Dark overlay
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }
            
            // Confetti
            ForEach(0..<30, id: \.self) { index in
                ConfettiPiece(delay: Double(index) * 0.05)
                    .opacity(confettiOpacity)
            }
            
            // Main content
            VStack(spacing: 24) {
                // Celebration icon
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    AppColors.secondaryAccent.opacity(0.3),
                                    AppColors.secondaryAccent.opacity(0.1)
                                ],
                                center: .center,
                                startRadius: 50,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .blur(radius: 20)
                    
                    Image(systemName: "star.fill")
                        .font(.system(size: 80))
                        .foregroundColor(AppColors.secondaryAccent)
                        .rotationEffect(.degrees(scale == 1.0 ? 0 : -180))
                }
                .scaleEffect(scale)
                
                VStack(spacing: 12) {
                    Text("🎉 Milestone Achieved!")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(milestone.title)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(AppColors.primaryAccent)
                    
                    if let fish = newFish {
                        VStack(spacing: 8) {
                            Text("You unlocked a new fish!")
                                .font(.system(size: 16))
                                .foregroundColor(AppColors.textSecondary)
                            
                            HStack(spacing: 12) {
                                Image(systemName: fish.systemImage)
                                    .font(.system(size: 32))
                                    .foregroundColor(fish.color)
                                
                                Text(fish.rawValue)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(AppColors.textPrimary)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(fish.color.opacity(0.2))
                            .cornerRadius(12)
                        }
                        .padding(.top, 8)
                    }
                }
                .opacity(opacity)
                
                Button(action: dismiss) {
                    Text("Awesome!")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(AppColors.deepOcean)
                        .frame(width: 200, height: 50)
                        .background(
                            LinearGradient(
                                colors: [AppColors.secondaryAccent, AppColors.primaryAccent],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(25)
                }
                .opacity(opacity)
            }
            .padding(40)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1.0
            }
            
            withAnimation(.easeOut(duration: 0.4).delay(0.2)) {
                opacity = 1.0
            }
            
            withAnimation(.easeIn(duration: 0.6).delay(0.1)) {
                confettiOpacity = 1.0
            }
        }
    }
    
    private func dismiss() {
        withAnimation(.easeOut(duration: 0.3)) {
            opacity = 0
            scale = 0.8
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isPresented = false
        }
    }
}

struct ConfettiPiece: View {
    let delay: Double
    @State private var yOffset: CGFloat = -100
    @State private var xOffset: CGFloat = 0
    @State private var rotation: Double = 0
    
    private let colors: [Color] = [
        AppColors.primaryAccent,
        AppColors.secondaryAccent,
        AppColors.progressColor,
        Color(hex: "FFD700"),
        Color(hex: "FF6B35")
    ]
    
    private let color = [AppColors.primaryAccent, AppColors.secondaryAccent, AppColors.progressColor].randomElement()!
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(color)
            .frame(width: 8, height: 12)
            .rotationEffect(.degrees(rotation))
            .offset(x: xOffset, y: yOffset)
            .position(
                x: CGFloat.random(in: 50...UIScreen.main.bounds.width - 50),
                y: 0
            )
            .onAppear {
                withAnimation(
                    Animation.linear(duration: Double.random(in: 2...4))
                        .delay(delay)
                ) {
                    yOffset = UIScreen.main.bounds.height + 100
                    xOffset = CGFloat.random(in: -50...50)
                    rotation = Double.random(in: 0...720)
                }
            }
    }
}
