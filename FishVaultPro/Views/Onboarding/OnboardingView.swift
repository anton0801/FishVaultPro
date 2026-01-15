// Views/Onboarding/OnboardingView.swift
import SwiftUI

struct OnboardingView: View {
    @Binding var showOnboarding: Bool
    @State private var currentPage = 0
    
    let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Track anything\nthat matters",
            description: "Monitor your goals, habits, and progress all in one place",
            systemImage: "list.bullet.clipboard.fill",
            accentColor: AppColors.primaryAccent
        ),
        OnboardingPage(
            title: "Keep everything\norganized",
            description: "Create custom vaults for different aspects of your life",
            systemImage: "square.stack.3d.up.fill",
            accentColor: AppColors.secondaryAccent
        ),
        OnboardingPage(
            title: "Your personal\ndigital vault",
            description: "Watch your progress come alive with animated fish",
            systemImage: "lock.shield.fill",
            accentColor: AppColors.progressColor
        )
    ]
    
    var body: some View {
        ZStack {
            AppColors.deepOcean.ignoresSafeArea()
            
            // Animated background bubbles
            ForEach(0..<15, id: \.self) { index in
                BubbleParticle(delay: Double(index) * 0.2)
                    .opacity(0.3)
            }
            
            VStack {
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index], pageIndex: index, currentPage: $currentPage)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Custom page indicator
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Capsule()
                            .fill(index == currentPage ? AppColors.primaryAccent : AppColors.textSecondary.opacity(0.3))
                            .frame(width: index == currentPage ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, 20)
                
                // Action button
                Button(action: {
                    if currentPage < pages.count - 1 {
                        withAnimation {
                            currentPage += 1
                        }
                    } else {
                        withAnimation {
                            showOnboarding = false
                        }
                    }
                }) {
                    Text(currentPage == pages.count - 1 ? "Get Started" : "Next")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(AppColors.deepOcean)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                colors: [AppColors.primaryAccent, AppColors.secondaryAccent],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: AppColors.primaryAccent.opacity(0.4), radius: 12, x: 0, y: 6)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
    }
}

struct OnboardingPage {
    let title: String
    let description: String
    let systemImage: String
    let accentColor: Color
}
