import XCTest

/// Launch performance tests for Turn Lab app.
final class TurnLabUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    /// Test that the app launches successfully.
    /// This catches immediate crashes and startup failures.
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Take a launch screenshot for reference
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)

        // The app should show either:
        // 1. Onboarding (for new users)
        // 2. Main app (for existing users)
        // Either is acceptable - just verify the app isn't crashing or blank
        let onboardingLoading = app.otherElements["onboarding_loading_view"]
        let quizQuestion = app.staticTexts["quiz_question_scenario"]
        let mainTabView = app.otherElements["main_tab_view"]
        let homeView = app.otherElements["home_view"]

        // Wait for any of these to appear
        let appLoaded = onboardingLoading.waitForExistence(timeout: 5)
            || quizQuestion.waitForExistence(timeout: 5)
            || mainTabView.waitForExistence(timeout: 5)
            || homeView.waitForExistence(timeout: 5)

        XCTAssertTrue(appLoaded, "App should load to either onboarding or main screen")
    }

    /// Measure launch performance.
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
