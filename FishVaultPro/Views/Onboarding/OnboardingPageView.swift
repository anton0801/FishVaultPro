// Views/Onboarding/OnboardingPageView.swift
import SwiftUI

struct OnboardingPageView: View {
    let page: OnboardingPage
    let pageIndex: Int
    @Binding var currentPage: Int
    
    @State private var iconScale: CGFloat = 0.5
    @State private var iconRotation: Double = -180
    @State private var textOpacity: Double = 0
    @State private var textOffset: CGFloat = 30
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Animated icon
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                page.accentColor.opacity(0.2),
                                page.accentColor.opacity(0.05)
                            ],
                            center: .center,
                            startRadius: 60,
                            endRadius: 120
                        )
                    )
                    .frame(width: 240, height: 240)
                    .blur(radius: 15)
                
                Image(systemName: page.systemImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundColor(page.accentColor)
                    .scaleEffect(iconScale)
                    .rotationEffect(.degrees(iconRotation))
                
                // Floating fish for last page
                if pageIndex == 2 {
                    FloatingFish()
                        .frame(width: 40, height: 40)
                        .offset(x: 80, y: -60)
                }
            }
            .frame(height: 280)
            
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.center)
                    .opacity(textOpacity)
                    .offset(y: textOffset)
                
                Text(page.description)
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .opacity(textOpacity)
                    .offset(y: textOffset)
            }
            
            Spacer()
        }
        .onChange(of: currentPage) { newValue in
            if newValue == pageIndex {
                animateIn()
            }
        }
        .onAppear {
            if currentPage == pageIndex {
                animateIn()
            }
        }
    }
    
    private func animateIn() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
            iconScale = 1.0
            iconRotation = 0
        }
        
        withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
            textOpacity = 1.0
            textOffset = 0
        }
    }
}

struct FloatingFish: View {
    @State private var yOffset: CGFloat = 0
    
    var body: some View {
        Image(systemName: "drop.fill")
            .resizable()
            .foregroundColor(AppColors.secondaryAccent)
            .offset(y: yOffset)
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: 2)
                        .repeatForever(autoreverses: true)
                ) {
                    yOffset = -10
                }
            }
    }
}
