// Views/Main/CreateVaultView.swift (ПОЛНАЯ ВЕРСИЯ)
import SwiftUI

struct CreateVaultView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: VaultListViewModel
    
    @State private var name = ""
    @State private var selectedType: VaultType = .numeric
    @State private var goal: String = ""
    @State private var unit: String = ""
    @State private var selectedCategory: VaultCategory = .other
    @State private var tagInput: String = ""
    @State private var tags: [String] = []
    
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
                        
                        // Category selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Category")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)
                            
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(VaultCategory.allCases, id: \.self) { category in
                                    CategorySelectionCard(
                                        category: category,
                                        isSelected: selectedCategory == category,
                                        action: { selectedCategory = category }
                                    )
                                }
                            }
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
                        
                        // Tags
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tags (Optional)")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppColors.textPrimary)
                            
                            HStack {
                                TextField("Add tag...", text: $tagInput)
                                    .textFieldStyle(CustomTextFieldStyle())
                                
                                Button(action: addTag) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(AppColors.primaryAccent)
                                }
                                .disabled(tagInput.isEmpty)
                            }
                            
                            if !tags.isEmpty {
                                FlowLayout(spacing: 8) {
                                    ForEach(tags, id: \.self) { tag in
                                        TagChip(tag: tag) {
                                            tags.removeAll { $0 == tag }
                                        }
                                    }
                                }
                                .padding(.top, 8)
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
    
    private func addTag() {
        let trimmed = tagInput.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty && !tags.contains(trimmed) {
            tags.append(trimmed)
            tagInput = ""
        }
    }
    
    private func createVault() {
        let vault = Vault(
            name: name,
            type: selectedType,
            createdAt: Date(),
            goal: Double(goal),
            unit: unit.isEmpty ? nil : unit,
            entries: [],
            category: selectedCategory,
            tags: tags,
            milestones: [],
            unlockedFish: [.basic]
        )
        
        viewModel.addVault(vault)
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Category Selection Card
struct CategorySelectionCard: View {
    let category: VaultCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.system(size: 28))
                    .foregroundColor(isSelected ? category.color : AppColors.textSecondary)
                
                Text(category.rawValue)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppColors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(
                isSelected ?
                    category.color.opacity(0.2) :
                    AppColors.cardBackground
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? category.color : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Type Selection Card
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

// MARK: - Tag Chip
struct TagChip: View {
    let tag: String
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 6) {
            Text(tag)
                .font(.system(size: 14))
                .foregroundColor(AppColors.textPrimary)
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
}

// MARK: - Flow Layout
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX, y: bounds.minY + result.frames[index].minY), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize
        var frames: [CGRect]
        
        init(in width: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var frames: [CGRect] = []
            var size: CGSize = .zero
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let subviewSize = subview.sizeThatFits(.unspecified)
                
                if x + subviewSize.width > width && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }
                
                frames.append(CGRect(origin: CGPoint(x: x, y: y), size: subviewSize))
                lineHeight = max(lineHeight, subviewSize.height)
                x += subviewSize.width + spacing
                size.width = max(size.width, x - spacing)
            }
            
            size.height = y + lineHeight
            self.size = size
            self.frames = frames
        }
    }
}
