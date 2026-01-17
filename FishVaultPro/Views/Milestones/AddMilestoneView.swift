import SwiftUI

struct AddMilestoneView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: VaultDetailViewModel
    
    @State private var title = ""
    @State private var targetValue = ""
    @State private var selectedReward: FishType?
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.deepOcean.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Title")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)
                            
                            TextField("e.g., First 100km", text: $title)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Target Value")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)
                            
                            TextField("Enter target", text: $targetValue)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Reward Fish (Optional)")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(FishType.allCases, id: \.self) { fish in
                                    FishRewardCard(
                                        fish: fish,
                                        isSelected: selectedReward == fish,
                                        action: { selectedReward = fish }
                                    )
                                }
                            }
                        }
                        
                        Spacer(minLength: 40)
                        
                        Button(action: saveMilestone) {
                            Text("Add Milestone")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(AppColors.deepOcean)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    LinearGradient(
                                        colors: [AppColors.secondaryAccent, AppColors.primaryAccent],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                        }
                        .disabled(title.isEmpty || targetValue.isEmpty)
                        .opacity(title.isEmpty || targetValue.isEmpty ? 0.5 : 1.0)
                    }
                    .padding(24)
                }
            }
            .navigationTitle("New Milestone")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(AppColors.textSecondary)
                }
            }
        }
    }
    
    private func saveMilestone() {
        guard let target = Double(targetValue) else { return }
        
        let milestone = Milestone(
            title: title,
            targetValue: target,
            reward: selectedReward
        )
        
        viewModel.vault.milestones.append(milestone)
        viewModel.saveVault()
        
        presentationMode.wrappedValue.dismiss()
    }
}

struct FishRewardCard: View {
    let fish: FishType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: fish.systemImage)
                    .font(.system(size: 28))
                    .foregroundColor(fish.color)
                
                Text(fish.rawValue)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(
                isSelected ?
                    fish.color.opacity(0.2) :
                    AppColors.cardBackground
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? fish.color : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
