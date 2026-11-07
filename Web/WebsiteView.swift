import SwiftUI
import WebKit
import UIKit

struct WebsiteView: View {
    let route: WebsiteRoute
    let language: AppLanguage
    @StateObject private var browser: WebsiteBrowser
    init(route: WebsiteRoute, language: AppLanguage) {
        self.route = route
        self.language = language
        _browser = StateObject(wrappedValue: WebsiteBrowser(url: route.url, language: language))
    }
    private func text(_ ar: String, _ en: String) -> String { language == .ar ? ar : en }
    var body: some View {
        VStack(spacing: 0) {
            if browser.isLoading {
                ProgressView(text("جارٍ التحميل", "Loading"))
                    .font(.caption).padding(8).frame(maxWidth: .infinity)
            }
            if browser.failed {
                ContentUnavailableView {
                    Label(text("تعذّر فتح الصفحة", "Unable to open page"), systemImage: "wifi.exclamationmark")
                } description: {
                    Text(text("تحقّق من الاتصال بالإنترنت ثم أعد المحاولة، أو افتح الصفحة في المتصفح.", "Check your connection and retry, or open the page in your browser."))
                } actions: {
                    Button(text("إعادة المحاولة", "Retry")) { browser.retry() }.buttonStyle(.borderedProminent)
                    Button(text("فتح في المتصفح", "Open in browser")) { browser.openCurrentInBrowser() }
                }
            } else {
                WebsiteSurface(browser: browser)
            }
        }
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 8) {
                Button { browser.goBack() } label: { Image(systemName: "chevron.backward").frame(width: 44, height: 44) }
                    .disabled(!browser.canGoBack).accessibilityLabel(text("الصفحة السابقة", "Back"))
                Button { browser.goForward() } label: { Image(systemName: "chevron.forward").frame(width: 44, height: 44) }
                    .disabled(!browser.canGoForward).accessibilityLabel(text("الصفحة التالية", "Forward"))
                Spacer()
                ShareLink(item: browser.currentURL) { Image(systemName: "square.and.arrow.up").frame(width: 44, height: 44) }
                    .accessibilityLabel(text("مشاركة الصفحة", "Share page"))
                Button { browser.retry() } label: { Image(systemName: "arrow.clockwise").frame(width: 44, height: 44) }
                    .accessibilityLabel(text("إعادة تحميل الصفحة", "Reload page"))
                Button { browser.openCurrentInBrowser() } label: { Image(systemName: "safari").frame(width: 44, height: 44) }
                    .accessibilityLabel(text("فتح في المتصفح", "Open in browser"))
            }
            .font(.system(size: 20)).frame(minHeight: 44).padding(.horizontal).background(.bar)
        }
        .alert(text("فتح رابط خارجي؟", "Open external link?"), isPresented: Binding(get: { browser.externalURL != nil }, set: { if !$0 { browser.externalURL = nil } }), presenting: browser.externalURL) { url in
            Button(text("فتح", "Open")) { browser.confirmExternal(url) }
            Button(text("إلغاء", "Cancel"), role: .cancel) { browser.externalURL = nil }
        } message: { url in Text(url.host ?? "") }
        .alert(text("تعذّر إكمال العملية", "Unable to complete action"), isPresented: $browser.showActionError) {
            Button(text("حسناً", "OK"), role: .cancel) {}
            Button(text("فتح في المتصفح", "Open in browser")) { browser.openCurrentInBrowser() }
        } message: {
            Text(text("قد لا يدعم هذا العرض الرابط أو التصدير المطلوب. جرّب المتصفح لإكمال العملية.", "This view may not support the requested link or export. Try your browser to continue."))
        }
        .sheet(item: $browser.sharedDownload, onDismiss: { browser.cleanSharedDownload() }) { item in
            DocumentShareSheet(url: item.url)
        }
        .onChange(of: language) { _, value in browser.language = value }
    }
}

private struct WebsiteSurface: UIViewRepresentable {
    @ObservedObject var browser: WebsiteBrowser
    func makeUIView(context: Context) -> WKWebView { browser.webView }
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

private struct DocumentShareSheet: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }
    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}
