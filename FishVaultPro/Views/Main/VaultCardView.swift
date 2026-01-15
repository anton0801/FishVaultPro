// Views/Main/VaultCardView.swift
import SwiftUI

struct VaultCardView: View {
    let vault: Vault
    @State private var animateFish = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(vault.name)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(vault.type.displayName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                // Animated fish
                FishAnimationView(speed: vault.fishSpeed)
                    .frame(width: 40, height: 40)
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppColors.textSecondary.opacity(0.2))
                        .frame(height: 8)
                    
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [AppColors.progressColor, AppColors.secondaryAccent],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(vault.progress), height: 8)
                        .animation(.spring(response: 0.6), value: vault.progress)
                }
            }
            .frame(height: 8)
            
            // Stats
            HStack {
                Text("\(vault.progressPercentage)%")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.primaryAccent)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12))
                    Text(vault.createdAt, style: .date)
                        .font(.system(size: 12))
                }
                .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding(20)
        .cardStyle()
    }
}
