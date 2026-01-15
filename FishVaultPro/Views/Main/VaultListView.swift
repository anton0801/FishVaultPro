// Views/Main/VaultListView.swift
import SwiftUI

struct VaultListView: View {
    @StateObject private var viewModel = VaultListViewModel()
    @State private var showingCreateVault = false
    @State private var selectedVault: Vault?
    
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
                        
                        Button(action: { showingCreateVault = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(AppColors.primaryAccent)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                    
                    if viewModel.vaults.isEmpty {
                        EmptyStateView(
                            title: "Your vault is empty",
                            subtitle: "Start adding entries",
                            action: { showingCreateVault = true }
                        )
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.vaults) { vault in
                                    NavigationLink(
                                        destination: VaultDetailView(vault: vault),
                                        tag: vault,
                                        selection: $selectedVault
                                    ) {
                                        VaultCardView(vault: vault)
                                            .transition(.scale.combined(with: .opacity))
                                    }
                                    .buttonStyle(ScaleButtonStyle())
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
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
