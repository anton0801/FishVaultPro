// Models/Vault.swift (UPDATED)
import Foundation

struct Vault: Identifiable, Codable {
    var id: String
    var name: String
    var type: VaultType
    var createdAt: Date
    var goal: Double?
    var unit: String?
    var entries: [VaultEntry]
    var category: VaultCategory // NEW
    var tags: [String] // NEW
    var milestones: [Milestone] // NEW
    var unlockedFish: [FishType] // NEW
    
    init(id: String = UUID().uuidString,
         name: String,
         type: VaultType,
         createdAt: Date = Date(),
         goal: Double? = nil,
         unit: String? = nil,
         entries: [VaultEntry] = [],
         category: VaultCategory = .other,
         tags: [String] = [],
         milestones: [Milestone] = [],
         unlockedFish: [FishType] = [.basic]) {
        self.id = id
        self.name = name
        self.type = type
        self.createdAt = createdAt
        self.goal = goal
        self.unit = unit
        self.entries = entries
        self.category = category
        self.tags = tags
        self.milestones = milestones
        self.unlockedFish = unlockedFish
    }
    
    // Custom decoding
    enum CodingKeys: String, CodingKey {
        case id, name, type, createdAt, goal, unit, entries, category, tags, milestones, unlockedFish
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        type = try container.decode(VaultType.self, forKey: .type)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        goal = try container.decodeIfPresent(Double.self, forKey: .goal)
        unit = try container.decodeIfPresent(String.self, forKey: .unit)
        entries = (try? container.decode([VaultEntry].self, forKey: .entries)) ?? []
        category = (try? container.decode(VaultCategory.self, forKey: .category)) ?? .other
        tags = (try? container.decode([String].self, forKey: .tags)) ?? []
        milestones = (try? container.decode([Milestone].self, forKey: .milestones)) ?? []
        unlockedFish = (try? container.decode([FishType].self, forKey: .unlockedFish)) ?? [.basic]
    }
    
    var progress: Double {
        guard !entries.isEmpty else { return 0 }
        
        switch type {
        case .numeric, .counter:
            let total = entries.reduce(0.0) { $0 + $1.value }
            guard let goal = goal, goal > 0 else { return 0 }
            return min(total / goal, 1.0)
            
        case .checklist:
            let completed = entries.filter { $0.isCompleted }.count
            let total = entries.count
            return total > 0 ? Double(completed) / Double(total) : 0
            
        case .progress:
            return entries.last?.value ?? 0
        }
    }
    
    var progressPercentage: Int {
        Int(progress * 100)
    }
    
    var fishSpeed: Double {
        0.5 + (progress * 1.5)
    }
    
    var currentValue: Double {
        switch type {
        case .numeric, .counter:
            return entries.reduce(0.0) { $0 + $1.value }
        case .checklist:
            return Double(entries.filter { $0.isCompleted }.count)
        case .progress:
            return progress * 100
        }
    }
    
    // NEW: Streak calculation
    var currentStreak: Int {
        guard !entries.isEmpty else { return 0 }
        
        let sortedEntries = entries.sorted { $0.date > $1.date }
        var streak = 0
        var currentDate = Calendar.current.startOfDay(for: Date())
        
        for entry in sortedEntries {
            let entryDate = Calendar.current.startOfDay(for: entry.date)
            let daysDifference = Calendar.current.dateComponents([.day], from: entryDate, to: currentDate).day ?? 0
            
            if daysDifference == streak {
                streak += 1
                currentDate = entryDate
            } else if daysDifference > streak {
                break
            }
        }
        
        return streak
    }
    
    // NEW: Best day
    var bestDay: (date: Date, value: Double)? {
        guard !entries.isEmpty else { return nil }
        let best = entries.max { $0.value < $1.value }
        return best.map { ($0.date, $0.value) }
    }
    
    // NEW: Average value
    var averageValue: Double {
        guard !entries.isEmpty else { return 0 }
        return entries.reduce(0.0) { $0 + $1.value } / Double(entries.count)
    }
    
    // NEW: Check and unlock fish
    mutating func checkAndUnlockFish() -> FishType? {
        let availableFish = FishType.allCases.filter { fish in
            fish.requiredProgress <= progress && !unlockedFish.contains(fish)
        }
        
        if let newFish = availableFish.first {
            unlockedFish.append(newFish)
            return newFish
        }
        return nil
    }
    
    // NEW: Check milestones
    mutating func checkMilestones() -> [Milestone] {
        var achieved: [Milestone] = []
        
        for index in milestones.indices {
            if !milestones[index].isAchieved && currentValue >= milestones[index].targetValue {
                milestones[index].isAchieved = true
                milestones[index].achievedDate = Date()
                achieved.append(milestones[index])
            }
        }
        
        return achieved
    }
}
