// Views/Main/VaultCardView.swift
import SwiftUI

struct VaultCardView: View {
    let vault: Vault
    @State private var animateFish = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Category badge
                HStack(spacing: 4) {
                    Image(systemName: vault.category.icon)
                        .font(.system(size: 12))
                    Text(vault.category.rawValue)
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(vault.category.color)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(vault.category.color.opacity(0.2))
                .cornerRadius(8)
                
                Spacer()
                
                // Unlocked fish indicator
                if vault.unlockedFish.count > 1 {
                    HStack(spacing: 2) {
                        ForEach(vault.unlockedFish.prefix(3), id: \.self) { fish in
                            Image(systemName: fish.systemImage)
                                .font(.system(size: 12))
                                .foregroundColor(fish.color)
                        }
                    }
                }
            }
            
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
                
                // Current fish
                if let currentFish = vault.unlockedFish.last {
                    Image(systemName: currentFish.systemImage)
                        .font(.system(size: 32))
                        .foregroundColor(currentFish.color)
                }
            }
            
            // Tags
            if !vault.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(vault.tags.prefix(3), id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.system(size: 11))
                                .foregroundColor(AppColors.primaryAccent)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(AppColors.primaryAccent.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                }
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
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 14))
                    Text("\(vault.currentStreak) day streak")
                        .font(.system(size: 14))
                }
                .foregroundColor(vault.currentStreak > 0 ? Color(hex: "FF6B35") : AppColors.textSecondary)
                
                Spacer()
                
                Text("\(vault.progressPercentage)%")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.primaryAccent)
            }
        }
        .padding(20)
        .cardStyle()
    }
}
