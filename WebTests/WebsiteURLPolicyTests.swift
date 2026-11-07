import XCTest
@testable import BSCKU

final class WebsiteURLPolicyTests: XCTestCase {
    func testOnlyExactHTTPSOriginIsInternal() throws {
        XCTAssertEqual(WebsiteURLPolicy.classify(try XCTUnwrap(URL(string: "https://biosci-ku.com/notes.html"))), .internalPage)
        for string in ["https://biosci-ku.com.evil.example/", "https://evil.example/?biosci-ku.com", "https://sub.biosci-ku.com/"] {
            XCTAssertEqual(WebsiteURLPolicy.classify(try XCTUnwrap(URL(string: string))), .externalPage)
        }
    }
    func testUnsafeURLsAreBlocked() throws {
        for string in ["http://biosci-ku.com/", "javascript:alert(1)", "file:///tmp/test", "data:text/html,test", "https://name@biosci-ku.com/", "https://biosci-ku.com:8443/", "tel:1234", "blob:https://biosci-ku.com/id"] {
            XCTAssertEqual(WebsiteURLPolicy.classify(try XCTUnwrap(URL(string: string))), .blocked)
        }
    }
    func testFilenameCannotTraverseDirectories() {
        for name in ["../../secret.pdf", "..\\..\\secret.pdf", ".", "", "/tmp/evil", String(repeating: "a", count: 200)] {
            let safe = WebsiteURLPolicy.safeFilename(name)
            XCTAssertFalse(safe.isEmpty)
            XCTAssertFalse(safe.contains("/"))
            XCTAssertFalse(safe.contains("\\"))
            XCTAssertLessThanOrEqual(safe.count, 100)
            XCTAssertNotEqual(safe, ".")
            XCTAssertNotEqual(safe, "..")
        }
    }
    func testOnlyOfficialSiteBlobsAreDownloadable() throws {
        XCTAssertTrue(WebsiteURLPolicy.isSiteBlob(try XCTUnwrap(URL(string: "blob:https://biosci-ku.com/6f1c0d2e-1111-2222-3333-444455556666"))))
        for string in ["blob:https://evil.example/id", "blob:https://biosci-ku.com.evil.example/id", "blob:http://biosci-ku.com/id",
                       "blob:null/id", "https://biosci-ku.com/id", "data:text/plain,hi"] {
            XCTAssertFalse(WebsiteURLPolicy.isSiteBlob(try XCTUnwrap(URL(string: string))), string)
        }
        // classify() is unchanged: blobs are never pages.
        XCTAssertEqual(WebsiteURLPolicy.classify(try XCTUnwrap(URL(string: "blob:https://biosci-ku.com/id"))), .blocked)
    }
    func testContactLinksNeedAValidSingleTarget() throws {
        XCTAssertEqual(WebsiteURLPolicy.contactTarget(try XCTUnwrap(URL(string: "mailto:biosciclub@gmail.com"))), "biosciclub@gmail.com")
        XCTAssertEqual(WebsiteURLPolicy.contactTarget(try XCTUnwrap(URL(string: "mailto:a.b@ku.edu.kw?subject=Hi"))), "a.b@ku.edu.kw")
        XCTAssertEqual(WebsiteURLPolicy.contactTarget(try XCTUnwrap(URL(string: "tel:+96524987000"))), "+96524987000")
        for string in ["mailto:", "mailto:not-an-address", "mailto:a@b@c", "mailto:a@b.com%0Abcc:x@y.com", "tel:", "tel:12;34",
                       "javascript:alert(1)", "https://biosci-ku.com/"] {
            XCTAssertNil(WebsiteURLPolicy.contactTarget(try XCTUnwrap(URL(string: string))), string)
        }
        XCTAssertEqual(WebsiteURLPolicy.displayTarget(try XCTUnwrap(URL(string: "mailto:biosciclub@gmail.com"))), "biosciclub@gmail.com")
        XCTAssertEqual(WebsiteURLPolicy.displayTarget(try XCTUnwrap(URL(string: "https://moodle.ku.edu.kw/login"))), "moodle.ku.edu.kw")
    }
    func testServiceDeepLinksMatchTheSiteTabs() {
        let expected = ["gpa": "tab=gpa", "planner": "tab=planner", "graduation": "tab=grad"]
        for (id, query) in expected {
            let route = WebsiteCatalog.routes.first { $0.id == id }
            XCTAssertEqual(route?.url.path, "/services.html", id)
            XCTAssertEqual(route?.url.query, query, id)
            XCTAssertEqual(route.map { WebsiteURLPolicy.classify($0.url) }, .internalPage, id)
        }
        // Home shows the first two services routes: keep the main tools first.
        let services = WebsiteCatalog.routes.filter { $0.category == .services }.prefix(2).map(\.id)
        XCTAssertEqual(Array(services), ["gpa", "planner"])
    }
    func testVerifiedVideoEmbedAllowlist() throws {
        XCTAssertTrue(WebsiteURLPolicy.isAllowedEmbeddedFrame(try XCTUnwrap(URL(string: "https://www.youtube-nocookie.com/embed/abcdefghijk"))))
        for string in ["https://www.youtube-nocookie.com/", "https://www.youtube-nocookie.com.evil.example/embed/a", "http://www.youtube-nocookie.com/embed/a"] {
            XCTAssertFalse(WebsiteURLPolicy.isAllowedEmbeddedFrame(try XCTUnwrap(URL(string: string))))
        }
    }
}
