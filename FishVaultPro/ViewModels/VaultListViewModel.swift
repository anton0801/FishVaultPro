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
        loadVaults()
        observeVaults()
    }
    
    func loadVaults() {
        isLoading = true
        
        firebaseService.fetchVaults { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let vaults):
                    self?.vaults = vaults
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func observeVaults() {
        firebaseService.observeVaults { [weak self] vaults in
            DispatchQueue.main.async {
                self?.vaults = vaults
            }
        }
    }
    
    func addVault(_ vault: Vault) {
        firebaseService.saveVault(vault) { [weak self] result in
            if case .failure(let error) = result {
                DispatchQueue.main.async {
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
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    deinit {
        firebaseService.removeAllObservers()
    }
}
