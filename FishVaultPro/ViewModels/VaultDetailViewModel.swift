// ViewModels/VaultDetailViewModel.swift
import Foundation
import Combine

class VaultDetailViewModel: ObservableObject {
    @Published var vault: Vault
    @Published var errorMessage: String?
    
    private let firebaseService = FirebaseService.shared
    
    init(vault: Vault) {
        self.vault = vault
    }
    
    func addEntry(_ entry: VaultEntry) {
        vault.entries.append(entry)
        saveVault()
    }
    
    func updateEntry(_ entry: VaultEntry) {
        if let index = vault.entries.firstIndex(where: { $0.id == entry.id }) {
            vault.entries[index] = entry
            saveVault()
        }
    }
    
    func deleteEntry(_ entry: VaultEntry) {
        vault.entries.removeAll { $0.id == entry.id }
        saveVault()
    }
    
    func toggleEntryCompletion(_ entry: VaultEntry) {
        if let index = vault.entries.firstIndex(where: { $0.id == entry.id }) {
            vault.entries[index].isCompleted.toggle()
            saveVault()
        }
    }
    
    private func saveVault() {
        firebaseService.saveVault(vault) { [weak self] result in
            if case .failure(let error) = result {
                DispatchQueue.main.async {
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
