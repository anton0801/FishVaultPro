// ViewModels/VaultListViewModel.swift
import Foundation
import Combine

class VaultListViewModel: ObservableObject {
    @Published var vaults: [Vault] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let firebaseService = FirebaseService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        print("🚀 VaultListViewModel initialized")
        loadVaults()
        observeVaults()
    }
    
    func loadVaults() {
        isLoading = true
        print("📥 Loading vaults...")
        
        firebaseService.fetchVaults { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let vaults):
                    print("✅ Loaded \(vaults.count) vaults")
                    self?.vaults = vaults
                case .failure(let error):
                    print("❌ Error loading vaults: \(error.localizedDescription)")
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func observeVaults() {
        print("👀 Observing vaults...")
        firebaseService.observeVaults { [weak self] vaults in
            DispatchQueue.main.async {
                print("🔄 Vaults updated: \(vaults.count) vaults")
                self?.vaults = vaults
            }
        }
    }
    
    func addVault(_ vault: Vault) {
        print("➕ Adding vault: \(vault.name)")
        firebaseService.saveVault(vault) { [weak self] result in
            if case .failure(let error) = result {
                DispatchQueue.main.async {
                    print("❌ Error adding vault: \(error.localizedDescription)")
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func deleteVault(_ vault: Vault) {
        print("🗑️ Deleting vault: \(vault.name)")
        firebaseService.deleteVault(vault.id) { [weak self] result in
            if case .failure(let error) = result {
                DispatchQueue.main.async {
                    print("❌ Error deleting vault: \(error.localizedDescription)")
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    deinit {
        firebaseService.removeAllObservers()
        print("👋 VaultListViewModel deinitialized")
    }
}
