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
    static func safeFilename(_ suggested: String) -> String {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "._-"))
        let cleaned = String(suggested.unicodeScalars.map { allowed.contains($0) ? Character(String($0)) : "_" })
            .trimmingCharacters(in: CharacterSet(charactersIn: "."))
        return cleaned.isEmpty ? "document" : String(cleaned.suffix(100))
    }
}
