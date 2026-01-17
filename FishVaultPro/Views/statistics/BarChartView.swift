

import SwiftUI

struct BarChartView: View {
    let data: [ChartDataPoint]
    
    private var maxValue: Double {
        data.map { $0.value }.max() ?? 1
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(data) { point in
                    VStack(spacing: 4) {
                        // Bar
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [AppColors.secondaryAccent, AppColors.primaryAccent],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .frame(height: max(4, (point.value / maxValue) * (geometry.size.height - 30)))
                        
                        // Label
                        Text(point.label)
                            .font(.system(size: 10))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}
