import Foundation
import Combine
import UIKit
@preconcurrency import WebKit

struct SharedDownload: Identifiable {
    let id = UUID()
    let url: URL
}

@MainActor
final class WebsiteBrowser: NSObject, ObservableObject, WKNavigationDelegate, WKUIDelegate, WKDownloadDelegate {
    let webView: WKWebView
    @Published var isLoading = false
    @Published var failed = false
    @Published var canGoBack = false
    @Published var canGoForward = false
    @Published var currentURL: URL
    @Published var externalURL: URL?
    @Published var showActionError = false
    @Published var sharedDownload: SharedDownload?
    private var destinations: [ObjectIdentifier: URL] = [:]
    private var sharedDirectory: URL?
    private var requestedURL: URL
    var language: AppLanguage

    init(url: URL, language: AppLanguage) {
        currentURL = url
        requestedURL = url
        self.language = language
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .default()
        configuration.allowsInlineMediaPlayback = true
        configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        webView = WKWebView(frame: .zero, configuration: configuration)
        super.init()
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.load(URLRequest(url: url))
    }
    func retry() {
        let retryFailedNavigation = failed
        failed = false
        if retryFailedNavigation || webView.url == nil { webView.load(URLRequest(url: requestedURL)) }
        else { webView.reload() }
    }
    func goBack() { failed = false; webView.goBack() }
    func goForward() { failed = false; webView.goForward() }
    func openCurrentInBrowser() {
        let url = failed ? requestedURL : currentURL
        guard WebsiteURLPolicy.classify(url) != .blocked else { return }
        UIApplication.shared.open(url)
    }
    func confirmExternal(_ url: URL) {
        guard WebsiteURLPolicy.classify(url) == .externalPage else { return }
        externalURL = nil
        UIApplication.shared.open(url)
    }
    private func refreshNavigation() {
        canGoBack = webView.canGoBack; canGoForward = webView.canGoForward
        if let url = webView.url, WebsiteURLPolicy.classify(url) == .internalPage { currentURL = url }
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        isLoading = true; failed = false
    }
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) { refreshNavigation() }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isLoading = false; failed = false; refreshNavigation()
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) { fail(error) }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) { fail(error) }
    private func fail(_ error: Error) {
        if (error as NSError).code == NSURLErrorCancelled { return }
        isLoading = false; failed = true
        canGoBack = webView.canGoBack; canGoForward = webView.canGoForward
    }
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) { isLoading = false; failed = true }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else { decisionHandler(.cancel); return }
        switch WebsiteURLPolicy.classify(url) {
        case .internalPage:
            if navigationAction.targetFrame?.isMainFrame != false && !navigationAction.shouldPerformDownload { requestedURL = url }
            decisionHandler(navigationAction.shouldPerformDownload ? .download : .allow)
        case .externalPage:
            if navigationAction.targetFrame?.isMainFrame == false && WebsiteURLPolicy.isAllowedEmbeddedFrame(url) {
                decisionHandler(.allow); return
            }
            // Never launch another app automatically; confirmation is required even for redirects.
            if navigationAction.targetFrame?.isMainFrame != false { isLoading = false; externalURL = url }
            decisionHandler(.cancel)
        case .blocked:
            if navigationAction.targetFrame?.isMainFrame != false { isLoading = false; showActionError = true }
            decisionHandler(.cancel)
        }
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        guard let url = navigationResponse.response.url else { decisionHandler(.cancel); return }
        if !navigationResponse.isForMainFrame && WebsiteURLPolicy.isAllowedEmbeddedFrame(url) { decisionHandler(.allow); return }
        guard WebsiteURLPolicy.classify(url) == .internalPage else {
            decisionHandler(.cancel); return
        }
        if let response = navigationResponse.response as? HTTPURLResponse, response.statusCode >= 400 {
            isLoading = false; failed = true; decisionHandler(.cancel); return
        }
        let attachment = (navigationResponse.response as? HTTPURLResponse)?.value(forHTTPHeaderField: "Content-Disposition")?.lowercased().hasPrefix("attachment") ?? false
        decisionHandler(navigationResponse.canShowMIMEType && !attachment ? .allow : .download)
    }
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard navigationAction.targetFrame == nil, let url = navigationAction.request.url else { return nil }
        switch WebsiteURLPolicy.classify(url) {
        case .internalPage: webView.load(navigationAction.request)
        case .externalPage: externalURL = url
        case .blocked: showActionError = true
        }
        return nil
    }
    func webView(_ webView: WKWebView, navigationAction: WKNavigationAction, didBecome download: WKDownload) {
        isLoading = false; download.delegate = self
    }
    func webView(_ webView: WKWebView, navigationResponse: WKNavigationResponse, didBecome download: WKDownload) {
        isLoading = false; download.delegate = self
    }
    func download(_ download: WKDownload, decideDestinationUsing response: URLResponse, suggestedFilename: String, completionHandler: @escaping (URL?) -> Void) {
        guard let url = response.url, WebsiteURLPolicy.classify(url) == .internalPage,
              response.expectedContentLength <= 100 * 1024 * 1024 else {
            showActionError = true; completionHandler(nil); return
        }
        do {
            let directory = FileManager.default.temporaryDirectory.appendingPathComponent("BSCKU-" + UUID().uuidString, isDirectory: true)
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: false)
            let destination = directory.appendingPathComponent(WebsiteURLPolicy.safeFilename(suggestedFilename))
            destinations[ObjectIdentifier(download)] = destination
            completionHandler(destination)
        } catch { showActionError = true; completionHandler(nil) }
    }
    func download(_ download: WKDownload, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, decisionHandler: @escaping (WKDownload.RedirectPolicy) -> Void) {
        let allowed = request.url.map { WebsiteURLPolicy.classify($0) == .internalPage } ?? false
        if !allowed { showActionError = true }
        decisionHandler(allowed ? .allow : .cancel)
    }
    func downloadDidFinish(_ download: WKDownload) {
        guard let destination = destinations.removeValue(forKey: ObjectIdentifier(download)) else { return }
        guard sharedDownload == nil && sharedDirectory == nil else {
            try? FileManager.default.removeItem(at: destination.deletingLastPathComponent())
            showActionError = true; return
        }
        sharedDirectory = destination.deletingLastPathComponent()
        sharedDownload = SharedDownload(url: destination)
    }
    func download(_ download: WKDownload, didFailWithError error: Error, resumeData: Data?) {
        if let destination = destinations.removeValue(forKey: ObjectIdentifier(download)) {
            try? FileManager.default.removeItem(at: destination.deletingLastPathComponent())
        }
        showActionError = true
    }
    func cleanSharedDownload() {
        if let directory = sharedDirectory { try? FileManager.default.removeItem(at: directory) }
        sharedDirectory = nil
    }
    func webView(_ webView: WKWebView, requestMediaCapturePermissionFor origin: WKSecurityOrigin, initiatedByFrame frame: WKFrameInfo, type: WKMediaCaptureType, decisionHandler: @escaping (WKPermissionDecision) -> Void) {
        decisionHandler(.deny)
    }
    private func present(_ alert: UIAlertController) -> Bool {
        guard var presenter = webView.window?.rootViewController else { return false }
        while let next = presenter.presentedViewController { presenter = next }
        guard !presenter.isBeingDismissed else { return false }
        presenter.present(alert, animated: true)
        return true
    }
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        guard frame.request.url.map({ WebsiteURLPolicy.classify($0) == .internalPage }) == true else { completionHandler(); return }
        let alert = UIAlertController(title: "BSC KU", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: language == .ar ? "حسناً" : "OK", style: .default) { _ in completionHandler() })
        if !present(alert) { completionHandler() }
    }
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        guard frame.request.url.map({ WebsiteURLPolicy.classify($0) == .internalPage }) == true else { completionHandler(false); return }
        let alert = UIAlertController(title: "BSC KU", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: language == .ar ? "إلغاء" : "Cancel", style: .cancel) { _ in completionHandler(false) })
        alert.addAction(UIAlertAction(title: language == .ar ? "متابعة" : "Continue", style: .default) { _ in completionHandler(true) })
        if !present(alert) { completionHandler(false) }
    }
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        guard frame.request.url.map({ WebsiteURLPolicy.classify($0) == .internalPage }) == true else { completionHandler(nil); return }
        let alert = UIAlertController(title: "BSC KU", message: prompt, preferredStyle: .alert)
        alert.addTextField { $0.text = defaultText }
        alert.addAction(UIAlertAction(title: language == .ar ? "إلغاء" : "Cancel", style: .cancel) { _ in completionHandler(nil) })
        alert.addAction(UIAlertAction(title: language == .ar ? "متابعة" : "Continue", style: .default) { [weak alert] _ in completionHandler(alert?.textFields?.first?.text) })
        if !present(alert) { completionHandler(nil) }
    }
}
