import XCTest
import UIKit
@testable import BSCKU

@MainActor
final class AppStoreTests: XCTestCase {
    func testFavoritesAndLanguagePersist() throws {
        let name = UUID().uuidString
        let defaults = try XCTUnwrap(UserDefaults(suiteName: name))
        defer { defaults.removePersistentDomain(forName: name) }
        let store = AppStore(defaults: defaults)
        let route = try XCTUnwrap(WebsiteCatalog.routes.first)
        XCTAssertEqual(store.language, .ar)
        store.toggleFavorite(route)
        store.language = .en
        let restored = AppStore(defaults: defaults)
        XCTAssertTrue(restored.favorites.contains(route.id))
        XCTAssertEqual(restored.language, .en)
        restored.toggleFavorite(route)
        XCTAssertFalse(restored.favorites.contains(route.id))
    }
    func testRecentVisitMovesToFrontAndClearPersists() throws {
        let name = UUID().uuidString
        let defaults = try XCTUnwrap(UserDefaults(suiteName: name))
        defer { defaults.removePersistentDomain(forName: name) }
        let store = AppStore(defaults: defaults)
        let first = try XCTUnwrap(WebsiteCatalog.routes.first)
        let last = try XCTUnwrap(WebsiteCatalog.routes.last)
        store.recordVisit(first); store.recordVisit(last); store.recordVisit(first)
        XCTAssertEqual(store.recentIDs.first, first.id)
        XCTAssertEqual(store.recentIDs.filter { $0 == first.id }.count, 1)
        store.clearHistory()
        XCTAssertTrue(AppStore(defaults: defaults).recentIDs.isEmpty)
    }
    func testBilingualSearchAndWhitespace() {
        let store = AppStore()
        XCTAssertEqual(store.matching(WebsiteCatalog.routes, query: "  ").count, WebsiteCatalog.routes.count)
        for route in WebsiteCatalog.routes {
            XCTAssertTrue(store.matching(WebsiteCatalog.routes, query: route.titleAR).contains(route))
            XCTAssertTrue(store.matching(WebsiteCatalog.routes, query: route.titleEN).contains(route))
        }
    }
    func testCatalogIdentifiersAndURLs() {
        let routes = WebsiteCatalog.routes
        XCTAssertFalse(routes.isEmpty)
        XCTAssertEqual(Set(routes.map(\.id)).count, routes.count)
        for route in routes {
            XCTAssertEqual(route.url.scheme, "https")
            XCTAssertEqual(route.url.host, "biosci-ku.com")
            XCTAssertNil(route.url.user)
            XCTAssertFalse(route.titleAR.isEmpty)
            XCTAssertFalse(route.titleEN.isEmpty)
            XCTAssertNotNil(UIImage(systemName: route.symbol), "Missing SF Symbol: \(route.symbol)")
        }
    }
    func testRouteURLCannotEscapeOfficialOrigin() {
        for path in ["https://evil.example/", "javascript:alert(1)", "//evil.example/", "https://biosci-ku.com.evil.example/", "https://user@biosci-ku.com/", "http://biosci-ku.com/"] {
            let route = WebsiteRoute(id: "test", path: path, titleAR: "اختبار", titleEN: "Test", subtitleAR: "", subtitleEN: "", symbol: "leaf", category: .study)
            XCTAssertEqual(route.url.absoluteString, "https://biosci-ku.com/")
        }
    }
}
