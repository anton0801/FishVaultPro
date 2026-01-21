import SwiftUI
import WebKit
import Combine

struct StatisticsView: View {
    @StateObject private var viewModel: StatisticsViewModel
    @Environment(\.presentationMode) var presentationMode
    
    init(vault: Vault) {
        _viewModel = StateObject(wrappedValue: StatisticsViewModel(vault: vault))
    }
    
    var body: some View {
        ZStack {
            AppColors.deepOcean.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Summary Cards
                    summarySection
                    
                    // Chart
                    chartSection
                    
                    // Streak
                    streakSection
                    
                    // Heatmap Calendar
                    heatmapSection
                    
                    // Milestones
                    if !viewModel.vault.milestones.isEmpty {
                        milestonesSection
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Statistics")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var summarySection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(
                title: "Total Entries",
                value: "\(viewModel.statistics.totalEntries)",
                icon: "list.bullet",
                color: AppColors.primaryAccent
            )
            
            StatCard(
                title: "Average",
                value: String(format: "%.1f", viewModel.statistics.averageValue),
                icon: "chart.bar.fill",
                color: AppColors.secondaryAccent
            )
            
            StatCard(
                title: "Current Streak",
                value: "\(viewModel.statistics.currentStreak) days",
                icon: "flame.fill",
                color: Color(hex: "FF6B35")
            )
            
            StatCard(
                title: "Progress",
                value: "\(viewModel.vault.progressPercentage)%",
                icon: "target",
                color: AppColors.progressColor
            )
        }
    }
    
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Progress Chart")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Picker("Period", selection: $viewModel.selectedPeriod) {
                    ForEach(StatisticsViewModel.TimePeriod.allCases, id: \.self) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 200)
            }
            
            BarChartView(data: viewModel.chartData())
                .frame(height: 200)
        }
        .padding(20)
        .cardStyle()
    }
    
    private var streakSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: "FF6B35"))
                        
                        Text("Current Streak")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                    }
                    
                    Text("\(viewModel.statistics.currentStreak) days in a row")
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                Text("\(viewModel.statistics.currentStreak)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.primaryAccent)
            }
            
            Divider()
                .background(AppColors.textSecondary.opacity(0.2))
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Longest Streak")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textSecondary)
                    
                    Text("\(viewModel.statistics.longestStreak) days")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                }
                
                Spacer()
                
                if let bestDay = viewModel.statistics.bestDay {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Best Day")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.textSecondary)
                        
                        Text("\(Int(bestDay.value))")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.secondaryAccent)
                    }
                }
            }
        }
        .padding(20)
        .cardStyle()
    }
    
    private var heatmapSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Activity Calendar")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
            
            HeatmapCalendarView(data: viewModel.statistics.heatmapData())
        }
        .padding(20)
        .cardStyle()
    }
    
    private var milestonesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Milestones")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary)
            
            ForEach(viewModel.vault.milestones) { milestone in
                MilestoneRowView(milestone: milestone, currentValue: viewModel.vault.currentValue)
            }
        }
        .padding(20)
        .cardStyle()
    }
}


struct VaultContentView: View {
    
    @State private var activeURL: String? = ""
    
    var body: some View {
        ZStack {
            if let urlString = activeURL,
               let url = URL(string: urlString) {
                DecoratedWebView(targetURL: url)
                    .ignoresSafeArea(.keyboard, edges: .bottom)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            boot()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("LoadTempURL"))) { _ in
            refresh()
        }
    }
    
    private func boot() {
        let temporary = UserDefaults.standard.string(forKey: "temp_url")
        let cached = UserDefaults.standard.string(forKey: "cached_endpoint") ?? ""
        
        activeURL = temporary ?? cached
        
        if temporary != nil {
            UserDefaults.standard.removeObject(forKey: "temp_url")
        }
    }
    
    private func refresh() {
        if let temporary = UserDefaults.standard.string(forKey: "temp_url"),
           !temporary.isEmpty {
            activeURL = nil
            activeURL = temporary
            UserDefaults.standard.removeObject(forKey: "temp_url")
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Text(title)
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }
}
