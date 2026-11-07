import XCTest
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
}
