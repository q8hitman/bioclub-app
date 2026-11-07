# Application-facing contract v1
Core/Contracts/WebsiteContract.swift is owned by Codex and frozen for initial integration.
WebsiteRoute: Identifiable, Hashable, Codable, Sendable; id String, path String, titleAR String, titleEN String, subtitleAR String, subtitleEN String, symbol String, category RouteCategory.
RouteCategory: study, services, activities, more (String raw values).
WebsiteRoute.url: URL computed against https://biosci-ku.com/.
WebsiteCatalog.routes: static [WebsiteRoute], verified routes only (Claude owns implementation).
WebsiteView: SwiftUI View initialized with route: WebsiteRoute, language: AppLanguage. Claude owns implementation. AppLanguage raw ar/en, declared in contract.
WebsiteView owns loading/error/offline retry, back/forward, external links, sharing and download UI. Persistent WKWebsiteDataStore.default; no tokens in UserDefaults. No unnecessary reload in updateUIView. No JS bridge or DOM modification without documented need. Native language changes UI only; don't invent web language parameters.
Route policy: only HTTPS exact biosci-ku.com host internal; other HTTPS via system browser with user action; deny custom, file, javascript and data navigation. Mail/tel only if explicit safe policy. Handle target=_blank. Downloads via WKDownload with safe temporary filenames and native share sheet; preserve session. Standard WKWebView file input supports system upload picker. Report unsupported cases explicitly.
Failure presentation must offer retry and open in browser. New web auth/external hosts require audit. Tests must exercise hostile URL classifications. Review implementation against contract before integration.

Change notes (Claude, 2026-11-07, no type changes): explicit Mail/tel policy = WebsiteURLPolicy.contactTarget (user tap or gesture popup, single well-formed target, native confirmation, classify unchanged). Site-origin blob: exports (WebsiteURLPolicy.isSiteBlob) may become WKDownloads only; never page loads. Catalog adds verified routes gpa, planner, graduation (services.html?tab=...) and privacy. See WEBSITE_AUDIT.md.
