import SwiftUI

struct MilestoneRowView: View {
    let milestone: Milestone
    let currentValue: Double
    
    private var progress: Double {
        min(currentValue / milestone.targetValue, 1.0)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Status icon
            ZStack {
                Circle()
                    .fill(milestone.isAchieved ? AppColors.secondaryAccent.opacity(0.2) : AppColors.textSecondary.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: milestone.isAchieved ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(milestone.isAchieved ? AppColors.secondaryAccent : AppColors.textSecondary)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(milestone.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.textPrimary)
                
                HStack(spacing: 8) {
                    Text("\(Int(currentValue)) / \(Int(milestone.targetValue))")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textSecondary)
                    
                    if let reward = milestone.reward {
                        HStack(spacing: 4) {
                            Image(systemName: reward.systemImage)
                                .font(.system(size: 12))
                            Text(reward.rawValue)
                                .font(.system(size: 12))
                        }
                        .foregroundColor(reward.color)
                    }
                }
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(AppColors.textSecondary.opacity(0.2))
                            .frame(height: 4)
                        
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [AppColors.secondaryAccent, AppColors.primaryAccent],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * CGFloat(progress), height: 4)
                    }
                }
                .frame(height: 4)
            }
        }
        .padding(12)
        .background(AppColors.cardBackground.opacity(0.5))
        .cornerRadius(12)
    }
}
