// Models/VaultEntry.swift
import Foundation

struct VaultEntry: Identifiable, Codable, Hashable {
    var id: String
    var value: Double
    var date: Date
    var note: String?
    var isCompleted: Bool
    
    init(id: String = UUID().uuidString,
         value: Double = 0,
         date: Date = Date(),
         note: String? = nil,
         isCompleted: Bool = false) {
        self.id = id
        self.value = value
        self.date = date
        self.note = note
        self.isCompleted = isCompleted
    }
    
    // Custom decoding to handle missing fields
    enum CodingKeys: String, CodingKey {
        case id, value, date, note, isCompleted
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        value = try container.decode(Double.self, forKey: .value)
        date = try container.decode(Date.self, forKey: .date)
        note = try container.decodeIfPresent(String.self, forKey: .note)
        isCompleted = (try? container.decode(Bool.self, forKey: .isCompleted)) ?? false
    }
}
