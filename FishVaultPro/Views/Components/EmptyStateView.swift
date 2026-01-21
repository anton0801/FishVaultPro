// Views/Components/EmptyStateView.swift
import SwiftUI
import WebKit

struct EmptyStateView: View {
    let title: String
    let subtitle: String
    let action: () -> Void
    
    @State private var floatOffset: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Floating fish
            Image(systemName: "drop.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .foregroundColor(AppColors.primaryAccent.opacity(0.5))
                .offset(y: floatOffset)
                .onAppear {
                    withAnimation(
                        Animation.easeInOut(duration: 2)
                            .repeatForever(autoreverses: true)
                    ) {
                        floatOffset = -10
                    }
                }
            
            VStack(spacing: 12) {
                Text(title)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                
                Text(subtitle)
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Button(action: action) {
                Text("Create Vault")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.deepOcean)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(AppColors.primaryAccent)
                    .cornerRadius(12)
            }
            .padding(.top, 16)
            
            Spacer()
        }
    }
}


extension InteractionHandler: WKNavigationDelegate {
    
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let destination = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        
        previousURL = destination
        
        if canNavigate(to: destination) {
            decisionHandler(.allow)
        } else {
            launchExternal(destination)
            decisionHandler(.cancel)
        }
    }
    
    private func canNavigate(to url: URL) -> Bool {
        let scheme = (url.scheme ?? "").lowercased()
        let fullPath = url.absoluteString.lowercased()
        
        let supportedSchemes: Set<String> = [
            "http", "https", "about", "blob", "data", "javascript", "file"
        ]
        
        let supportedPaths = ["srcdoc", "about:blank", "about:srcdoc"]
        
        return supportedSchemes.contains(scheme) ||
               supportedPaths.contains { fullPath.hasPrefix($0) } ||
               fullPath == "about:blank"
    }
    
    private func launchExternal(_ url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func webView(
        _ webView: WKWebView,
        didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!
    ) {
        redirectionCounter += 1
        
        if redirectionCounter > maxRedirections {
            webView.stopLoading()
            
            if let fallback = previousURL {
                webView.load(URLRequest(url: fallback))
            }
            
            redirectionCounter = 0
            return
        }
        
        previousURL = webView.url
        coordinator?.cookieDecorator.capture(from: webView)
    }
    
    func webView(
        _ webView: WKWebView,
        didFinish navigation: WKNavigation!
    ) {
        injectDecorations(into: webView)
    }
    
    private func injectDecorations(into view: WKWebView) {
        let decorationScript = """
        (function() {
            const viewport = document.createElement('meta');
            viewport.name = 'viewport';
            viewport.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
            document.head.appendChild(viewport);
            
            const styles = document.createElement('style');
            styles.textContent = 'body { touch-action: pan-x pan-y; } input, textarea { font-size: 16px !important; }';
            document.head.appendChild(styles);
            
            document.addEventListener('gesturestart', e => e.preventDefault());
            document.addEventListener('gesturechange', e => e.preventDefault());
        })();
        """
        
        view.evaluateJavaScript(decorationScript) { _, error in
            if let error = error {
                print("Decoration injection error: \(error)")
            }
        }
    }
    
    func webView(
        _ webView: WKWebView,
        didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        let code = (error as NSError).code
        
        if code == NSURLErrorHTTPTooManyRedirects,
           let fallback = previousURL {
            webView.load(URLRequest(url: fallback))
        }
    }
    
    func webView(
        _ webView: WKWebView,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
           let trust = challenge.protectionSpace.serverTrust {
            completionHandler(.useCredential, URLCredential(trust: trust))
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}

