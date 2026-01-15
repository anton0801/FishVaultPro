// Views/Detail/ProgressOverviewView.swift
import SwiftUI

struct ProgressOverviewView: View {
    let vault: Vault
    
    var body: some View {
        VStack(spacing: 20) {
            // Circular progress
            CircularProgressView(progress: vault.progress, size: 160)
            
            // Stats
            HStack(spacing: 32) {
                StatItem(
                    title: "Entries",
                    value: "\(vault.entries.count)",
                    icon: "list.bullet"
                )
                
                StatItem(
                    title: "Progress",
                    value: "\(vault.progressPercentage)%",
                    icon: "chart.line.uptrend.xyaxis"
                )
                
                if let goal = vault.goal {
                    StatItem(
                        title: "Goal",
                        value: "\(Int(goal))",
                        icon: "flag.fill"
                    )
                }
            }
        }
        .padding(24)
        .cardStyle()
    }
}

struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(AppColors.primaryAccent)
            
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
            
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(AppColors.textSecondary)
        }
    }
}
