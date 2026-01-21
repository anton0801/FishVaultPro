// Views/Components/FishAnimationView.swift
import WebKit
import SwiftUI

struct FishAnimationView: View {
    let speed: Double
    @State private var xOffset: CGFloat = 0
    @State private var isFlipped = false
    
    var body: some View {
        Image(systemName: "drop.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(AppColors.primaryAccent)
            .scaleEffect(x: isFlipped ? -1 : 1, y: 1)
            .offset(x: xOffset)
            .onAppear {
                startSwimming()
            }
    }
    
    private func startSwimming() {
        let duration = 3.0 / speed
        
        withAnimation(
            Animation.linear(duration: duration)
                .repeatForever(autoreverses: false)
        ) {
            xOffset = 20
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration / 2) {
            isFlipped.toggle()
        }
    }
}

extension InteractionHandler: WKUIDelegate {
    
    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        guard navigationAction.targetFrame == nil,
              let coordinator = coordinator,
              let base = coordinator.baseView else {
            return nil
        }
        
        let overlay = WKWebView(frame: .zero, configuration: configuration)
        
        decorateOverlay(overlay, within: base)
        attachSwipeGesture(to: overlay)
        
        coordinator.overlayViews.append(overlay)
        
        if let url = navigationAction.request.url,
           url.absoluteString != "about:blank" {
            overlay.load(navigationAction.request)
        }
        
        return overlay
    }
    
    private func decorateOverlay(_ overlay: WKWebView, within base: WKWebView) {
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.scrollView.isScrollEnabled = true
        overlay.scrollView.minimumZoomScale = 1.0
        overlay.scrollView.maximumZoomScale = 1.0
        overlay.scrollView.bounces = false
        overlay.scrollView.bouncesZoom = false
        overlay.allowsBackForwardNavigationGestures = true
        overlay.navigationDelegate = self
        overlay.uiDelegate = self
        
        base.addSubview(overlay)
        
        NSLayoutConstraint.activate([
            overlay.leadingAnchor.constraint(equalTo: base.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: base.trailingAnchor),
            overlay.topAnchor.constraint(equalTo: base.topAnchor),
            overlay.bottomAnchor.constraint(equalTo: base.bottomAnchor)
        ])
    }
    
    private func attachSwipeGesture(to view: WKWebView) {
        let swipe = UIScreenEdgePanGestureRecognizer(
            target: self,
            action: #selector(handleSwipeGesture(_:))
        )
        swipe.edges = .left
        view.addGestureRecognizer(swipe)
    }
    
    @objc private func handleSwipeGesture(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        guard recognizer.state == .ended,
              let view = recognizer.view as? WKWebView else {
            return
        }
        
        if view.canGoBack {
            view.goBack()
        } else if coordinator?.overlayViews.last === view {
            coordinator?.goBack(toURL: nil)
        }
    }
    
    func webView(
        _ webView: WKWebView,
        runJavaScriptAlertPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping () -> Void
    ) {
        completionHandler()
    }
}
