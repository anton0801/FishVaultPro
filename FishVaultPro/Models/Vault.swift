// Models/Vault.swift
import Foundation

struct Vault: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    var type: VaultType
    var createdAt: Date
    var goal: Double?
    var unit: String?
    var entries: [VaultEntry]
    
    init(id: String = UUID().uuidString,
         name: String,
         type: VaultType,
         createdAt: Date = Date(),
         goal: Double? = nil,
         unit: String? = nil,
         entries: [VaultEntry] = []) {
        self.id = id
        self.name = name
        self.type = type
        self.createdAt = createdAt
        self.goal = goal
        self.unit = unit
        self.entries = entries
    }
    
    // Custom decoding to handle missing entries
    enum CodingKeys: String, CodingKey {
        case id, name, type, createdAt, goal, unit, entries
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
}
