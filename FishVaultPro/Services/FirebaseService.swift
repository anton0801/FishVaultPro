// Services/FirebaseService.swift
import Foundation
import FirebaseDatabase
import Combine

class FirebaseService: ObservableObject {
    static let shared = FirebaseService()
    private let ref = Database.database().reference()
    private var userId: String {
        AuthService.shared.currentUserId ?? "anonymous"
    }
    
    // MARK: - Vault Operations
    
    func saveVault(_ vault: Vault, completion: @escaping (Result<Void, Error>) -> Void) {
        let vaultDict = vaultToDict(vault)
        
        ref.child("users").child(userId).child("vaults").child(vault.id).setValue(vaultDict) { error, _ in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Error saving vault: \(error.localizedDescription)")
                    completion(.failure(error))
                } else {
                    print("✅ Vault saved successfully: \(vault.name)")
                    completion(.success(()))
                }
            }
        }
    }
    
    func fetchVaults(completion: @escaping (Result<[Vault], Error>) -> Void) {
        ref.child("users").child(userId).child("vaults").observeSingleEvent(of: .value) { snapshot in
            DispatchQueue.main.async {
                guard snapshot.exists() else {
                    print("ℹ️ No vaults found")
                    completion(.success([]))
                    return
                }
                
                var vaults: [Vault] = []
                
                for child in snapshot.children {
                    guard let snap = child as? DataSnapshot,
                          let dict = snap.value as? [String: Any] else {
                        continue
                    }
                    
                    if let vault = self.dictToVault(dict) {
                        vaults.append(vault)
                        print("✅ Parsed vault: \(vault.name)")
                    } else {
                        print("⚠️ Failed to parse vault from dict")
                    }
                }
                
                vaults.sort { $0.createdAt > $1.createdAt }
                print("📦 Fetched \(vaults.count) vaults")
                completion(.success(vaults))
            }
        }
    }
    
    func deleteVault(_ vaultId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        ref.child("users").child(userId).child("vaults").child(vaultId).removeValue { error, _ in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Error deleting vault: \(error.localizedDescription)")
                    completion(.failure(error))
                } else {
                    print("✅ Vault deleted successfully")
                    completion(.success(()))
                }
            }
        }
    }
    
    func observeVaults(completion: @escaping ([Vault]) -> Void) {
        ref.child("users").child(userId).child("vaults").observe(.value) { snapshot in
            DispatchQueue.main.async {
                guard snapshot.exists() else {
                    completion([])
                    return
                }
                
                var vaults: [Vault] = []
                
                for child in snapshot.children {
                    guard let snap = child as? DataSnapshot,
                          let dict = snap.value as? [String: Any],
                          let vault = self.dictToVault(dict) else {
                        continue
                    }
                    vaults.append(vault)
                }
                
                vaults.sort { $0.createdAt > $1.createdAt }
                completion(vaults)
            }
        }
    }
    
    // MARK: - Conversion Methods
    
    private func vaultToDict(_ vault: Vault) -> [String: Any] {
        var dict: [String: Any] = [
            "id": vault.id,
            "name": vault.name,
            "type": vault.type.rawValue,
            "createdAt": vault.createdAt.timeIntervalSince1970,
            "category": vault.category.rawValue,
            "tags": vault.tags,
            "unlockedFish": vault.unlockedFish.map { $0.rawValue }
        ]
        
        if let goal = vault.goal {
            dict["goal"] = goal
        }
        
        if let unit = vault.unit {
            dict["unit"] = unit
        }
        
        dict["entries"] = vault.entries.map { entryToDict($0) }
        dict["milestones"] = vault.milestones.map { milestoneToDict($0) }
        
        return dict
    }

    private func milestoneToDict(_ milestone: Milestone) -> [String: Any] {
        var dict: [String: Any] = [
            "id": milestone.id,
            "title": milestone.title,
            "targetValue": milestone.targetValue,
            "isAchieved": milestone.isAchieved
        ]
        
        if let achievedDate = milestone.achievedDate {
            dict["achievedDate"] = achievedDate.timeIntervalSince1970
        }
        
        if let reward = milestone.reward {
            dict["reward"] = reward.rawValue
        }
        
        return dict
    }

    private func dictToVault(_ dict: [String: Any]) -> Vault? {
        guard let id = dict["id"] as? String,
              let name = dict["name"] as? String,
              let typeString = dict["type"] as? String,
              let type = VaultType(rawValue: typeString),
              let createdAtTimestamp = dict["createdAt"] as? Double else {
            return nil
        }
        
        let createdAt = Date(timeIntervalSince1970: createdAtTimestamp)
        let goal = dict["goal"] as? Double
        let unit = dict["unit"] as? String
        
        let categoryString = dict["category"] as? String ?? "other"
        let category = VaultCategory(rawValue: categoryString) ?? .other
        
        let tags = dict["tags"] as? [String] ?? []
        
        let unlockedFishStrings = dict["unlockedFish"] as? [String] ?? ["basic"]
        let unlockedFish = unlockedFishStrings.compactMap { FishType(rawValue: $0) }
        
        var entries: [VaultEntry] = []
        if let entriesArray = dict["entries"] as? [[String: Any]] {
            entries = entriesArray.compactMap { dictToEntry($0) }
        }
        
        var milestones: [Milestone] = []
        if let milestonesArray = dict["milestones"] as? [[String: Any]] {
            milestones = milestonesArray.compactMap { dictToMilestone($0) }
        }
        
        return Vault(
            id: id,
            name: name,
            type: type,
            createdAt: createdAt,
            goal: goal,
            unit: unit,
            entries: entries,
            category: category,
            tags: tags,
            milestones: milestones,
            unlockedFish: unlockedFish.isEmpty ? [.basic] : unlockedFish
        )
    }

    private func dictToMilestone(_ dict: [String: Any]) -> Milestone? {
        guard let id = dict["id"] as? String,
              let title = dict["title"] as? String,
              let targetValue = dict["targetValue"] as? Double else {
            return nil
        }
        
        let isAchieved = dict["isAchieved"] as? Bool ?? false
        
        var achievedDate: Date?
        if let timestamp = dict["achievedDate"] as? Double {
            achievedDate = Date(timeIntervalSince1970: timestamp)
        }
        
        var reward: FishType?
        if let rewardString = dict["reward"] as? String {
            reward = FishType(rawValue: rewardString)
        }
        
        return Milestone(
            title: title,
            targetValue: targetValue,
            isAchieved: isAchieved,
            achievedDate: achievedDate,
            reward: reward
        )
    }
    
    private func entryToDict(_ entry: VaultEntry) -> [String: Any] {
        var dict: [String: Any] = [
            "id": entry.id,
            "value": entry.value,
            "date": entry.date.timeIntervalSince1970,
            "isCompleted": entry.isCompleted
        ]
        
        if let note = entry.note {
            dict["note"] = note
        }
        
        return dict
    }
    
    private func dictToEntry(_ dict: [String: Any]) -> VaultEntry? {
        guard let id = dict["id"] as? String,
              let value = dict["value"] as? Double,
              let dateTimestamp = dict["date"] as? Double else {
            return nil
        }
        
        let date = Date(timeIntervalSince1970: dateTimestamp)
        let note = dict["note"] as? String
        let isCompleted = dict["isCompleted"] as? Bool ?? false
        
        return VaultEntry(
            id: id,
            value: value,
            date: date,
            note: note,
            isCompleted: isCompleted
        )
    }
    
    func removeAllObservers() {
        ref.child("users").child(userId).child("vaults").removeAllObservers()
    }
}
