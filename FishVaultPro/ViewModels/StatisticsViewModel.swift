// ViewModels/StatisticsViewModel.swift
import Foundation
import Combine
import WebKit

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

final class WebCoordinator: ObservableObject {
    
    @Published var overlayViews: [WKWebView] = []
    @Published private(set) var baseView: WKWebView!
    
    let cookieDecorator = CookieDecorator()
    
    private var observations = Set<AnyCancellable>()
    
    func createBaseView() {
        let configuration = assembleConfiguration()
        baseView = WKWebView(frame: .zero, configuration: configuration)
        decorateView(baseView)
    }
    
    private func assembleConfiguration() -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = true
        configuration.preferences = preferences
        
        let pagePreferences = WKWebpagePreferences()
        pagePreferences.allowsContentJavaScript = true
        configuration.defaultWebpagePreferences = pagePreferences
        
        return configuration
    }
    
    private func decorateView(_ view: WKWebView) {
        view.scrollView.minimumZoomScale = 1.0
        view.scrollView.maximumZoomScale = 1.0
        view.scrollView.bounces = false
        view.scrollView.bouncesZoom = false
        view.allowsBackForwardNavigationGestures = true
    }
    
    func goBack(toURL: URL? = nil) {
        if !overlayViews.isEmpty {
            if let last = overlayViews.last {
                last.removeFromSuperview()
                overlayViews.removeLast()
            }
            
            if let destination = toURL {
                baseView.load(URLRequest(url: destination))
            }
        } else if baseView.canGoBack {
            baseView.goBack()
        }
    }
    
    func reloadView() {
        baseView.reload()
    }
}

