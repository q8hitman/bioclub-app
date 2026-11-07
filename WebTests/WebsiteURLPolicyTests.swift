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
    func testVerifiedVideoEmbedAllowlist() throws {
        XCTAssertTrue(WebsiteURLPolicy.isAllowedEmbeddedFrame(try XCTUnwrap(URL(string: "https://www.youtube-nocookie.com/embed/abcdefghijk"))))
        for string in ["https://www.youtube-nocookie.com/", "https://www.youtube-nocookie.com.evil.example/embed/a", "http://www.youtube-nocookie.com/embed/a"] {
            XCTAssertFalse(WebsiteURLPolicy.isAllowedEmbeddedFrame(try XCTUnwrap(URL(string: string))))
        }
    }
}
