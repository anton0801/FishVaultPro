// ViewModels/StatisticsViewModel.swift
import Foundation
import Combine

class StatisticsViewModel: ObservableObject {
    @Published var vault: Vault
    @Published var selectedPeriod: TimePeriod = .week
    
    var statistics: VaultStatistics {
        VaultStatistics(vault: vault)
    }
    
    init(vault: Vault) {
        self.vault = vault
    }
    
    enum TimePeriod: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
    func chartData() -> [ChartDataPoint] {
        switch selectedPeriod {
        case .week:
            return statistics.weeklyData()
        case .month:
            return statistics.monthlyData()
        case .year:
            return statistics.yearlyData()
        }
    }
}
