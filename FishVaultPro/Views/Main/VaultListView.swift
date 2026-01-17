// Views/Main/VaultListView.swift (UPDATED)
import SwiftUI

struct VaultListView: View {
    @StateObject private var viewModel = VaultListViewModel()
    @State private var showingCreateVault = false
    @State private var selectedVault: Vault?
    @State private var selectedCategory: VaultCategory?
    @State private var searchText = ""
    @State private var showingSettings = false
    
    private var filteredVaults: [Vault] {
        var vaults = viewModel.vaults
        
        // Filter by category
        if let category = selectedCategory {
            vaults = vaults.filter { $0.category == category }
        }
        
        // Filter by search
        if !searchText.isEmpty {
            vaults = vaults.filter { vault in
                vault.name.localizedCaseInsensitiveContains(searchText) ||
                vault.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        return vaults
    }
    
    private var groupedVaults: [VaultCategory: [Vault]] {
        Dictionary(grouping: filteredVaults, by: { $0.category })
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.deepOcean.ignoresSafeArea()
                
                // Background bubbles
                ForEach(0..<10, id: \.self) { index in
                    BubbleParticle(delay: Double(index) * 0.3)
                        .opacity(0.15)
                }
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("My Vaults")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                        
                        Spacer()
                        
                        Button(action: { showingSettings = true }) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 24))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        
                        Button(action: { showingCreateVault = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(AppColors.primaryAccent)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                    
                    // Search bar
                    SearchBar(text: $searchText)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 12)
                    
                    // Category filter
                    CategoryFilterView(selectedCategory: $selectedCategory)
                        .padding(.bottom, 16)
                    
                    if filteredVaults.isEmpty {
                        EmptyStateView(
                            title: selectedCategory != nil ? "No vaults in this category" : "Your vault is empty",
                            subtitle: "Start adding entries",
                            action: { showingCreateVault = true }
                        )
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 24) {
                                ForEach(VaultCategory.allCases, id: \.self) { category in
                                    if let vaults = groupedVaults[category], !vaults.isEmpty {
                                        CategorySection(
                                            category: category,
                                            vaults: vaults,
                                            onVaultTap: { vault in
                                                selectedVault = vault
                                            }
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 8)
                            .padding(.bottom, 24)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingCreateVault) {
                CreateVaultView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .background(
                NavigationLink(
                    destination: selectedVault.map { VaultDetailView(vault: $0) },
                    isActive: Binding(
                        get: { selectedVault != nil },
                        set: { if !$0 { selectedVault = nil } }
                    )
                ) {
                    EmptyView()
                }
                .hidden()
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppColors.textSecondary)
            
            TextField("Search vaults...", text: $text)
                .foregroundColor(AppColors.textPrimary)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
        .padding(12)
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }
}

struct CategoryFilterView: View {
    @Binding var selectedCategory: VaultCategory?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                CategoryChip(
                    title: "All",
                    icon: "square.grid.2x2.fill",
                    color: AppColors.primaryAccent,
                    isSelected: selectedCategory == nil,
                    action: { selectedCategory = nil }
                )
                
                ForEach(VaultCategory.allCases, id: \.self) { category in
                    CategoryChip(
                        title: category.rawValue,
                        icon: category.icon,
                        color: category.color,
                        isSelected: selectedCategory == category,
                        action: { selectedCategory = category }
                    )
                }
            }
            .padding(.horizontal, 24)
        }
    }
}

struct CategoryChip: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(isSelected ? AppColors.deepOcean : color)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? color : AppColors.cardBackground)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(color.opacity(0.5), lineWidth: isSelected ? 0 : 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct CategorySection: View {
    let category: VaultCategory
    let vaults: [Vault]
    let onVaultTap: (Vault) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.system(size: 16))
                    .foregroundColor(category.color)
                
                Text(category.rawValue)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Text("(\(vaults.count))")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
            }
            .padding(.horizontal, 4)
            
            ForEach(vaults) { vault in
                Button(action: { onVaultTap(vault) }) {
                    VaultCardView(vault: vault)
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
    }
}
