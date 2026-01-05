import XCTest

/// Comprehensive UI tests for Turn Lab app.
/// Tests critical user flows to catch issues before TestFlight uploads.
final class TurnLabUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()

        // Reset app state for fresh onboarding test
        app.launchArguments = ["UI_TESTING", "--reset-state"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Critical Path Tests

    /// Test that the onboarding quiz loads and displays questions.
    /// This was the critical bug - the app was stuck on loading.
    func testOnboardingQuizLoads() throws {
        // Wait for either loading to complete or quiz content to appear
        let loadingView = app.otherElements["onboarding_loading_view"]
        let questionScenario = app.staticTexts["quiz_question_scenario"]

        // First, the loading view may appear briefly
        if loadingView.waitForExistence(timeout: 2) {
            // Loading appeared, wait for it to disappear
            let questionAppeared = questionScenario.waitForExistence(timeout: 10)
            XCTAssertTrue(questionAppeared, "Quiz question should appear after loading completes")
        } else {
            // Loading was fast, question should be visible
            let questionAppeared = questionScenario.waitForExistence(timeout: 5)
            XCTAssertTrue(questionAppeared, "Quiz question should be visible")
        }

        // Verify the Next button exists (proves quiz UI is functional)
        let nextButton = app.buttons["quiz_next_button"]
        XCTAssertTrue(nextButton.waitForExistence(timeout: 2), "Next button should be visible")

        // Next button should be disabled until an option is selected
        XCTAssertFalse(nextButton.isEnabled, "Next button should be disabled before selecting an option")
    }

    /// Test selecting quiz options and navigating forward.
    func testQuizOptionSelectionAndNavigation() throws {
        // Wait for quiz to load
        let questionScenario = app.staticTexts["quiz_question_scenario"]
        XCTAssertTrue(questionScenario.waitForExistence(timeout: 10), "Quiz should load")

        // Find and tap the first quiz option
        // Options have ids like "quiz_option_q1_a", "quiz_option_q1_b", etc.
        let options = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'quiz_option_'"))
        XCTAssertGreaterThan(options.count, 0, "Quiz options should be available")

        // Tap the first option
        let firstOption = options.element(boundBy: 0)
        XCTAssertTrue(firstOption.waitForExistence(timeout: 2), "First option should exist")
        firstOption.tap()

        // Now Next button should be enabled
        let nextButton = app.buttons["quiz_next_button"]
        XCTAssertTrue(nextButton.waitForExistence(timeout: 2), "Next button should exist")

        // Wait a moment for the state to update
        sleep(1)
        XCTAssertTrue(nextButton.isEnabled, "Next button should be enabled after selecting an option")

        // Tap next to go to question 2
        nextButton.tap()

        // Wait for transition
        sleep(1)

        // Back button should now appear
        let backButton = app.buttons["quiz_back_button"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 3), "Back button should appear on second question")
    }

    /// Test completing the entire onboarding quiz flow.
    /// This is the most critical test - if this passes, onboarding works.
    func testCompleteOnboardingFlow() throws {
        // Wait for quiz to load
        let questionScenario = app.staticTexts["quiz_question_scenario"]
        XCTAssertTrue(questionScenario.waitForExistence(timeout: 10), "Quiz should load")

        // Answer all 12 questions
        for questionNumber in 1...12 {
            // Wait for current question
            sleep(1)

            // Find options for current question
            let options = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'quiz_option_'"))

            if options.count > 0 {
                // Tap the first option available
                let firstOption = options.element(boundBy: 0)
                if firstOption.exists && firstOption.isHittable {
                    firstOption.tap()
                }
            }

            // Wait for selection to register
            sleep(1)

            // Tap Next or Finish button
            if questionNumber == 12 {
                // Last question - look for Finish button
                let finishButton = app.buttons["quiz_finish_button"]
                if finishButton.waitForExistence(timeout: 2) && finishButton.isEnabled {
                    finishButton.tap()
                }
            } else {
                // Not last question - tap Next
                let nextButton = app.buttons["quiz_next_button"]
                if nextButton.waitForExistence(timeout: 2) && nextButton.isEnabled {
                    nextButton.tap()
                }
            }
        }

        // Should now see the result screen
        let resultTitle = app.staticTexts["quiz_result_title"]
        XCTAssertTrue(resultTitle.waitForExistence(timeout: 5), "Quiz result screen should appear after completing all questions")

        // Result header should be visible
        let resultHeader = app.otherElements["quiz_result_header"]
        XCTAssertTrue(resultHeader.exists, "Quiz result header should be visible")

        // Start button should be available
        let startButton = app.buttons["quiz_start_button"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 2), "Start at This Level button should be visible")
    }

    /// Test that tapping Start at This Level completes onboarding and shows main app.
    func testOnboardingCompletionShowsMainApp() throws {
        // Complete the quiz (reuse logic from above but simplified)
        completeOnboardingQuiz()

        // Wait for result screen
        let startButton = app.buttons["quiz_start_button"]
        XCTAssertTrue(startButton.waitForExistence(timeout: 10), "Start button should appear on result screen")

        // Tap to complete onboarding
        startButton.tap()

        // Should now see the main tab view or home view
        let mainTabView = app.otherElements["main_tab_view"]
        let homeView = app.otherElements["home_view"]

        // Either one appearing means onboarding completed successfully
        let mainAppAppeared = mainTabView.waitForExistence(timeout: 10) || homeView.waitForExistence(timeout: 5)
        XCTAssertTrue(mainAppAppeared, "Main app should appear after completing onboarding")
    }

    /// Test going back through quiz questions.
    func testQuizBackNavigation() throws {
        // Wait for quiz to load
        let questionScenario = app.staticTexts["quiz_question_scenario"]
        XCTAssertTrue(questionScenario.waitForExistence(timeout: 10), "Quiz should load")

        // Answer first question and go to second
        let options = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'quiz_option_'"))
        if options.count > 0 {
            options.element(boundBy: 0).tap()
        }

        sleep(1)

        let nextButton = app.buttons["quiz_next_button"]
        if nextButton.exists && nextButton.isEnabled {
            nextButton.tap()
        }

        sleep(1)

        // Should now be on question 2, back button should exist
        let backButton = app.buttons["quiz_back_button"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 3), "Back button should appear on second question")

        // Tap back
        backButton.tap()

        sleep(1)

        // Back button should disappear on first question
        XCTAssertFalse(backButton.exists, "Back button should not exist on first question")
    }

    // MARK: - Helper Methods

    /// Helper to complete the onboarding quiz by answering all questions.
    private func completeOnboardingQuiz() {
        // Wait for quiz to load
        let questionScenario = app.staticTexts["quiz_question_scenario"]
        guard questionScenario.waitForExistence(timeout: 10) else {
            XCTFail("Quiz failed to load")
            return
        }

        // Answer all 12 questions
        for questionNumber in 1...12 {
            sleep(1)

            let options = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'quiz_option_'"))

            if options.count > 0 {
                let firstOption = options.element(boundBy: 0)
                if firstOption.exists && firstOption.isHittable {
                    firstOption.tap()
                }
            }

            sleep(1)

            if questionNumber == 12 {
                let finishButton = app.buttons["quiz_finish_button"]
                if finishButton.waitForExistence(timeout: 2) && finishButton.isEnabled {
                    finishButton.tap()
                }
            } else {
                let nextButton = app.buttons["quiz_next_button"]
                if nextButton.waitForExistence(timeout: 2) && nextButton.isEnabled {
                    nextButton.tap()
                }
            }
        }
    }
}
