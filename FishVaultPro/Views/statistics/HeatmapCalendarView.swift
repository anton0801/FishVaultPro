import SwiftUI

struct HeatmapCalendarView: View {
    let data: [Date: Double]
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    private let calendar = Calendar.current
    
    private var dates: [Date] {
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -83, to: endDate)! // 12 weeks
        
        var dates: [Date] = []
        var currentDate = startDate
        
        while currentDate <= endDate {
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return dates
    }
    
    private var maxValue: Double {
        data.values.max() ?? 1
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Weekday headers
            HStack(spacing: 4) {
                ForEach(["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"], id: \.self) { day in
                    Text(day)
                        .font(.system(size: 10))
                        .foregroundColor(AppColors.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar grid
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(dates, id: \.self) { date in
                    let startOfDay = calendar.startOfDay(for: date)
                    let value = data[startOfDay] ?? 0
                    let intensity = maxValue > 0 ? value / maxValue : 0
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(cellColor(for: intensity))
                        .frame(height: 12)
                }
            }
            
            // Legend
            HStack(spacing: 8) {
                Text("Less")
                    .font(.system(size: 10))
                    .foregroundColor(AppColors.textSecondary)
                
                ForEach(0..<5) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(cellColor(for: Double(index) / 4.0))
                        .frame(width: 12, height: 12)
                }
                
                Text("More")
                    .font(.system(size: 10))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
    }
    
    private func cellColor(for intensity: Double) -> Color {
        if intensity == 0 {
            return AppColors.textSecondary.opacity(0.1)
        } else if intensity < 0.25 {
            return AppColors.secondaryAccent.opacity(0.3)
        } else if intensity < 0.5 {
            return AppColors.secondaryAccent.opacity(0.5)
        } else if intensity < 0.75 {
            return AppColors.secondaryAccent.opacity(0.7)
        } else {
            return AppColors.secondaryAccent
        }
    }
}
