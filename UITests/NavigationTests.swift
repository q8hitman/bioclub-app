import XCTest

final class NavigationTests: XCTestCase {
    func testLaunchAndNativeNavigation() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.staticTexts["BSC KU"].firstMatch.waitForExistence(timeout: 10))
        let more = app.tabBars.buttons["المزيد"]
        if more.exists { more.tap() } else { app.staticTexts["المزيد"].firstMatch.tap() }
        XCTAssertTrue(app.staticTexts["المفضلة"].firstMatch.waitForExistence(timeout: 5))
    }
}
