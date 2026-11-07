import Foundation

public enum AppLanguage: String, Codable, CaseIterable, Sendable { case ar, en }
public enum RouteCategory: String, Codable, CaseIterable, Sendable { case study, services, activities, more }
public struct WebsiteRoute: Identifiable, Hashable, Codable, Sendable {
    public let id: String
    public let path: String
    public let titleAR: String
    public let titleEN: String
    public let subtitleAR: String
    public let subtitleEN: String
    public let symbol: String
    public let category: RouteCategory
    public init(id: String, path: String, titleAR: String, titleEN: String, subtitleAR: String, subtitleEN: String, symbol: String, category: RouteCategory) {
        self.id = id; self.path = path; self.titleAR = titleAR; self.titleEN = titleEN
        self.subtitleAR = subtitleAR; self.subtitleEN = subtitleEN; self.symbol = symbol; self.category = category
    }
    public var url: URL { URL(string: path, relativeTo: URL(string: "https://biosci-ku.com/")!)!.absoluteURL }
    public func title(_ language: AppLanguage) -> String { language == .ar ? titleAR : titleEN }
    public func subtitle(_ language: AppLanguage) -> String { language == .ar ? subtitleAR : subtitleEN }
}
