// Views/Main/CreateVaultView.swift
import SwiftUI

struct CreateVaultView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: VaultListViewModel
    
    @State private var name = ""
    @State private var selectedType: VaultType = .numeric
    @State private var goal: String = ""
    @State private var unit: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.deepOcean.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Vault name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Vault Name")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)
                            
                            TextField("Enter name", text: $name)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Type selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Vault Type")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(VaultType.allCases, id: \.self) { type in
                                    TypeSelectionCard(
                                        type: type,
                                        isSelected: selectedType == type,
                                        action: { selectedType = type }
                                    )
                                }
                            }
                        }
                        
                        // Goal (for numeric/progress types)
                        if selectedType == .numeric || selectedType == .progress {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Goal")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(AppColors.textPrimary)
                                
                                TextField("Enter goal", text: $goal)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(CustomTextFieldStyle())
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Unit (Optional)")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(AppColors.textPrimary)
                                
                                TextField("e.g., km, hours", text: $unit)
                                    .textFieldStyle(CustomTextFieldStyle())
                            }
                        }
                        
                        Spacer(minLength: 40)
                        
                        // Create button
                        Button(action: createVault) {
                            Text("Create Vault")
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
                        .disabled(name.isEmpty)
                        .opacity(name.isEmpty ? 0.5 : 1.0)
                    }
                    .padding(24)
                }
            }
            .navigationTitle("New Vault")
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
    
    private func createVault() {
        let vault = Vault(
            name: name,
            type: selectedType,
            createdAt: Date(),
            goal: Double(goal),
            unit: unit.isEmpty ? nil : unit,
            entries: []
        )
        
        viewModel.addVault(vault)
        presentationMode.wrappedValue.dismiss()
    }
}

struct TypeSelectionCard: View {
    let type: VaultType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: type.icon)
                    .font(.system(size: 32))
                    .foregroundColor(isSelected ? AppColors.primaryAccent : AppColors.textSecondary)
                
                Text(type.displayName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(
                isSelected ?
                    AppColors.primaryAccent.opacity(0.15) :
                    AppColors.cardBackground
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? AppColors.primaryAccent : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.system(size: 16))
            .foregroundColor(AppColors.textPrimary)
            .padding()
            .background(AppColors.cardBackground)
            .cornerRadius(12)
    }
}
