import Foundation

enum WebsiteURLDisposition: Equatable { case internalPage, externalPage, blocked }

enum WebsiteURLPolicy {
    static func isAllowedEmbeddedFrame(_ url: URL) -> Bool {
        classify(url) == .externalPage && url.host?.lowercased() == "www.youtube-nocookie.com"
            && url.path.hasPrefix("/embed/")
    }
    static func classify(_ url: URL) -> WebsiteURLDisposition {
        guard url.scheme?.lowercased() == "https", let host = url.host?.lowercased(),
              url.user == nil, url.password == nil,
              url.port == nil || url.port == 443 else { return .blocked }
        return host == "biosci-ku.com" ? .internalPage : .externalPage
    }

    /// Narrow exception to `.blocked` for downloads only: a `blob:` URL created
    /// by the official site itself (`blob:https://biosci-ku.com/<uuid>`).
    /// services.html exports files with `URL.createObjectURL` + `a.download`;
    /// without this, those exports fail. Never allowed as a page navigation.
    static func isSiteBlob(_ url: URL) -> Bool {
        guard url.scheme?.lowercased() == "blob" else { return false }
        let inner = String(url.absoluteString.dropFirst("blob:".count))
        guard let origin = URL(string: inner) else { return false }
        return classify(origin) == .internalPage
    }

    /// Explicit safe policy for contact links (contract: "Mail/tel only if
    /// explicit safe policy"). The site links club and advisor e-mail addresses
    /// as `mailto:`. A contact link is only ever handed to the system after the
    /// student confirms it, and only when it came from a tap in the page.
    static func contactTarget(_ url: URL) -> String? {
        guard let scheme = url.scheme?.lowercased(), scheme == "mailto" || scheme == "tel" else { return nil }
        let raw = String(url.absoluteString.dropFirst(scheme.count + 1))
        let target = (raw.split(separator: "?", maxSplits: 1).first.map(String.init) ?? "")
            .removingPercentEncoding ?? ""
        let allowed = scheme == "tel"
            ? CharacterSet(charactersIn: "+0123456789-() ")
            : CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "@._%+-"))
        guard !target.isEmpty, target.count <= 254,
              target.unicodeScalars.allSatisfy({ $0.isASCII && allowed.contains($0) }),
              scheme == "tel" || target.filter({ $0 == "@" }).count == 1
        else { return nil }
        return target
    }

    /// Text shown in the "open external link?" confirmation.
    static func displayTarget(_ url: URL) -> String {
        contactTarget(url) ?? url.host ?? ""
    }

    static func safeFilename(_ suggested: String) -> String {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "._-"))
        let cleaned = String(suggested.unicodeScalars.map { allowed.contains($0) ? Character(String($0)) : "_" })
            .trimmingCharacters(in: CharacterSet(charactersIn: "."))
        return cleaned.isEmpty ? "document" : String(cleaned.suffix(100))
    }
}
