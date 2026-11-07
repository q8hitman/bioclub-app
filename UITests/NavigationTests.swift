import XCTest

final class NavigationTests: XCTestCase {
    @MainActor
    func testLaunchAndNativeNavigation() {
        let app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
        XCTAssertTrue(app.staticTexts["BSC KU"].firstMatch.waitForExistence(timeout: 10))
        capture("Arabic home", app: app)
        let more = app.tabBars.buttons["المزيد"]
        if more.exists { more.tap() } else { app.staticTexts["المزيد"].firstMatch.tap() }
        XCTAssertTrue(app.staticTexts["المفضلة"].firstMatch.waitForExistence(timeout: 5))
        capture("Arabic more", app: app)
        app.buttons["languagePicker"].tap()
        app.buttons["English"].tap()
        XCTAssertTrue(app.staticTexts["Favorites"].firstMatch.waitForExistence(timeout: 5))
        capture("English more", app: app)
        XCUIDevice.shared.orientation = .landscapeLeft
        XCTAssertTrue(app.staticTexts["Favorites"].firstMatch.waitForExistence(timeout: 5))
        capture("English landscape", app: app)
        XCUIDevice.shared.orientation = .portrait
    }

    @MainActor
    private func capture(_ name: String, app: XCUIApplication) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
