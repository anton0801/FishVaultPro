// Views/Components/EmptyStateView.swift
import SwiftUI

struct EmptyStateView: View {
    let title: String
    let subtitle: String
    let action: () -> Void
    
    @State private var floatOffset: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Floating fish
            Image(systemName: "drop.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .foregroundColor(AppColors.primaryAccent.opacity(0.5))
                .offset(y: floatOffset)
                .onAppear {
                    withAnimation(
                        Animation.easeInOut(duration: 2)
                            .repeatForever(autoreverses: true)
                    ) {
                        floatOffset = -10
                    }
                }
            
            VStack(spacing: 12) {
                Text(title)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Text(subtitle)
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Button(action: action) {
                Text("Create Vault")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.deepOcean)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(AppColors.primaryAccent)
                    .cornerRadius(12)
            }
            .padding(.top, 16)
            
            Spacer()
        }
    }
}
