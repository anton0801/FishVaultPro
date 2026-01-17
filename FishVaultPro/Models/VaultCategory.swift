// Models/VaultCategory.swift
import SwiftUI

enum VaultCategory: String, Codable, CaseIterable {
    case health = "Health"
    case finance = "Finance"
    case learning = "Learning"
    case productivity = "Productivity"
    case habits = "Habits"
    case fitness = "Fitness"
    case personal = "Personal"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .health: return "heart.fill"
        case .finance: return "dollarsign.circle.fill"
        case .learning: return "book.fill"
        case .productivity: return "chart.line.uptrend.xyaxis"
        case .habits: return "checkmark.circle.fill"
        case .fitness: return "figure.run"
        case .personal: return "person.fill"
        case .other: return "folder.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .health: return Color(hex: "FF6B6B")
        case .finance: return Color(hex: "4ECDC4")
        case .learning: return Color(hex: "FFE66D")
        case .productivity: return AppColors.primaryAccent
        case .habits: return AppColors.secondaryAccent
        case .fitness: return Color(hex: "95E1D3")
        case .personal: return Color(hex: "C7CEEA")
        case .other: return AppColors.textSecondary
        }
    }
}
