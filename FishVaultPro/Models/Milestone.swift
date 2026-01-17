// Models/Milestone.swift
import Foundation
import SwiftUI

struct Milestone: Identifiable, Codable, Hashable, Equatable {
    var id: String = UUID().uuidString
    var title: String
    var targetValue: Double
    var isAchieved: Bool
    var achievedDate: Date?
    var reward: FishType?
    
    init(title: String, targetValue: Double, isAchieved: Bool = false, achievedDate: Date? = nil, reward: FishType? = nil) {
        self.title = title
        self.targetValue = targetValue
        self.isAchieved = isAchieved
        self.achievedDate = achievedDate
        self.reward = reward
    }
    
    static func == (lhs: Milestone, rhs: Milestone) -> Bool {
        lhs.id == rhs.id
    }
}

enum FishType: String, Codable, CaseIterable {
    case basic = "Basic Fish"
    case clownfish = "Clownfish"
    case goldfish = "Goldfish"
    case angelfish = "Angelfish"
    case beta = "Beta Fish"
    case shark = "Shark"
    case dolphin = "Dolphin"
    case whale = "Whale"
    
    var systemImage: String {
        switch self {
        case .basic: return "drop.fill"
        case .clownfish: return "figure.wave"
        case .goldfish: return "sparkles"
        case .angelfish: return "star.fill"
        case .beta: return "flame.fill"
        case .shark: return "bolt.fill"
        case .dolphin: return "moon.stars.fill"
        case .whale: return "crown.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .basic: return AppColors.primaryAccent
        case .clownfish: return Color(hex: "FF6B35")
        case .goldfish: return Color(hex: "FFD700")
        case .angelfish: return Color(hex: "B19CD9")
        case .beta: return Color(hex: "FF1744")
        case .shark: return Color(hex: "455A64")
        case .dolphin: return Color(hex: "64B5F6")
        case .whale: return Color(hex: "9575CD")
        }
    }
    
    var requiredProgress: Double {
        switch self {
        case .basic: return 0
        case .clownfish: return 0.25
        case .goldfish: return 0.40
        case .angelfish: return 0.50
        case .beta: return 0.65
        case .shark: return 0.75
        case .dolphin: return 0.90
        case .whale: return 1.0
        }
    }
}
