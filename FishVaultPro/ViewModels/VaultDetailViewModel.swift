// ViewModels/VaultDetailViewModel.swift (UPDATED)
import Foundation
import Combine

class VaultDetailViewModel: ObservableObject {
    @Published var vault: Vault
    @Published var errorMessage: String?
    @Published var showCelebration = false
    @Published var celebrationMilestone: Milestone?
    @Published var celebrationFish: FishType?
    
    private let firebaseService = FirebaseService.shared
    
    init(vault: Vault) {
        self.vault = vault
    }
    
    func addEntry(_ entry: VaultEntry) {
        vault.entries.append(entry)
        checkAchievements()
        saveVault()
    }
    
    func updateEntry(_ entry: VaultEntry) {
        if let index = vault.entries.firstIndex(where: { $0.id == entry.id }) {
            vault.entries[index] = entry
            checkAchievements()
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
            checkAchievements()
            saveVault()
        }
    }
    
    private func checkAchievements() {
        // Check milestones
        let achievedMilestones = vault.checkMilestones()
        
        // Check fish unlocks
        let newFish = vault.checkAndUnlockFish()
        
        // Show celebration if any achievement
        if let milestone = achievedMilestones.first {
            celebrationMilestone = milestone
            celebrationFish = newFish
            showCelebration = true
        } else if let fish = newFish {
            // Create a fake milestone for fish unlock
            celebrationMilestone = Milestone(
                title: "Progress Achievement!",
                targetValue: vault.currentValue,
                isAchieved: true,
                achievedDate: Date(),
                reward: fish
            )
            celebrationFish = fish
            showCelebration = true
        }
    }
    
    func saveVault() {
        firebaseService.saveVault(vault) { [weak self] result in
            if case .failure(let error) = result {
                DispatchQueue.main.async {
                    print("❌ Error saving vault: \(error.localizedDescription)")
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
