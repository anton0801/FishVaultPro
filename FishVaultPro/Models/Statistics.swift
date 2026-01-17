// Models/Statistics.swift
import Foundation

struct VaultStatistics {
    let vault: Vault
    
    var totalEntries: Int {
        vault.entries.count
    }
    
    var currentStreak: Int {
        vault.currentStreak
    }
    
    var longestStreak: Int {
        calculateLongestStreak()
    }
    
    var averageValue: Double {
        vault.averageValue
    }
    
    var totalValue: Double {
        vault.entries.reduce(0.0) { $0 + $1.value }
    }
    
    var bestDay: (date: Date, value: Double)? {
        vault.bestDay
    }
    
    var completionRate: Double {
        guard vault.type == .checklist, !vault.entries.isEmpty else { return 0 }
        let completed = vault.entries.filter { $0.isCompleted }.count
        return Double(completed) / Double(vault.entries.count)
    }
    
    // Weekly data
    func weeklyData() -> [ChartDataPoint] {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -6, to: endDate)!
        
        return generateDataPoints(from: startDate, to: endDate, component: .day)
    }
    
    // Monthly data
    func monthlyData() -> [ChartDataPoint] {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -29, to: endDate)!
        
        return generateDataPoints(from: startDate, to: endDate, component: .day)
    }
    
    // Yearly data
    func yearlyData() -> [ChartDataPoint] {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .month, value: -11, to: endDate)!
        
        return generateDataPoints(from: startDate, to: endDate, component: .month)
    }
    
    // Heatmap data for calendar
    func heatmapData() -> [Date: Double] {
        var data: [Date: Double] = [:]
        let calendar = Calendar.current
        
        for entry in vault.entries {
            let startOfDay = calendar.startOfDay(for: entry.date)
            data[startOfDay, default: 0] += entry.value
        }
        
        return data
    }
    
    private func generateDataPoints(from startDate: Date, to endDate: Date, component: Calendar.Component) -> [ChartDataPoint] {
        let calendar = Calendar.current
        var dataPoints: [ChartDataPoint] = []
        var currentDate = startDate
        
        while currentDate <= endDate {
            let nextDate = calendar.date(byAdding: component, value: 1, to: currentDate)!
            
            let entriesInRange = vault.entries.filter { entry in
                entry.date >= currentDate && entry.date < nextDate
            }
            
            let value = entriesInRange.reduce(0.0) { $0 + $1.value }
            
            let label: String
            if component == .day {
                label = currentDate.formatted(.dateTime.weekday(.abbreviated))
            } else {
                label = currentDate.formatted(.dateTime.month(.abbreviated))
            }
            
            dataPoints.append(ChartDataPoint(date: currentDate, value: value, label: label))
            currentDate = nextDate
        }
        
        return dataPoints
    }
    
    private func calculateLongestStreak() -> Int {
        guard !vault.entries.isEmpty else { return 0 }
        
        let sortedDates = vault.entries
            .map { Calendar.current.startOfDay(for: $0.date) }
            .sorted()
        
        var longestStreak = 1
        var currentStreak = 1
        
        for i in 1..<sortedDates.count {
            let daysDiff = Calendar.current.dateComponents([.day], from: sortedDates[i-1], to: sortedDates[i]).day ?? 0
            
            if daysDiff == 1 {
                currentStreak += 1
                longestStreak = max(longestStreak, currentStreak)
            } else if daysDiff > 1 {
                currentStreak = 1
            }
        }
        
        return longestStreak
    }
}

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
    let label: String
}
