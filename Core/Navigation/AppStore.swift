import SwiftUI

@MainActor @Observable
final class AppStore {
    var language: AppLanguage { didSet { defaults.set(language.rawValue, forKey: "language") } }
    var favorites: Set<String> { didSet { defaults.set(Array(favorites), forKey: "favorites") } }
    var recentIDs: [String] { didSet { defaults.set(recentIDs, forKey: "recents") } }
    private let defaults: UserDefaults
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        language = AppLanguage(rawValue: defaults.string(forKey: "language") ?? "ar") ?? .ar
        favorites = Set(defaults.stringArray(forKey: "favorites") ?? [])
        recentIDs = Array((defaults.stringArray(forKey: "recents") ?? []).prefix(20))
    }
    func toggleFavorite(_ route: WebsiteRoute) {
        if favorites.contains(route.id) { favorites.remove(route.id) } else { favorites.insert(route.id) }
    }
    func recordVisit(_ route: WebsiteRoute) {
        recentIDs = Array(([route.id] + recentIDs.filter { $0 != route.id }).prefix(20))
    }
    func clearHistory() { recentIDs = [] }
    func text(_ ar: String, _ en: String) -> String { language == .ar ? ar : en }
    func matching(_ routes: [WebsiteRoute], query: String) -> [WebsiteRoute] {
        let term = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !term.isEmpty else { return routes }
        return routes.filter { [$0.titleAR, $0.titleEN, $0.subtitleAR, $0.subtitleEN].contains { $0.localizedStandardContains(term) } }
    }
}
