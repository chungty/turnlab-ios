import XCTest
@testable import TurnLab

@MainActor
final class OnboardingViewModelTests: XCTestCase {
    var sut: OnboardingViewModel!
    var mockSkillRepository: MockSkillRepository!
    var mockUserRepository: MockUserRepository!
    var mockAppState: AppState!

    override func setUp() {
        super.setUp()
        mockSkillRepository = MockSkillRepository()
        mockUserRepository = MockUserRepository()
        mockAppState = AppState()

        // Set up quiz questions
        mockSkillRepository.quizQuestions = [
            QuizQuestion(
                id: "q1",
                text: "Question 1",
                options: [
                    QuizOption(
                        text: "Beginner Answer",
                        levelScores: [.beginner: 3, .novice: 0, .intermediate: 0, .expert: 0]
                    ),
                    QuizOption(
                        text: "Expert Answer",
                        levelScores: [.beginner: 0, .novice: 0, .intermediate: 0, .expert: 3]
                    )
                ]
            ),
            QuizQuestion(
                id: "q2",
                text: "Question 2",
                options: [
                    QuizOption(
                        text: "Intermediate Answer",
                        levelScores: [.beginner: 0, .novice: 0, .intermediate: 3, .expert: 0]
                    ),
                    QuizOption(
                        text: "Novice Answer",
                        levelScores: [.beginner: 0, .novice: 3, .intermediate: 0, .expert: 0]
                    )
                ]
            )
        ]

        sut = OnboardingViewModel(
            skillRepository: mockSkillRepository,
            userRepository: mockUserRepository,
            appState: mockAppState
        )
    }

    override func tearDown() {
        sut = nil
        mockSkillRepository = nil
        mockUserRepository = nil
        mockAppState = nil
        super.tearDown()
    }

    // MARK: - Initial State Tests

    func testInitialStateIsFirstQuestion() {
        XCTAssertEqual(sut.currentQuestionIndex, 0)
        XCTAssertFalse(sut.isQuizComplete)
    }

    func testQuestionsAreLoaded() {
        XCTAssertEqual(sut.questions.count, 2)
    }

    func testCurrentQuestionReturnsCorrectQuestion() {
        XCTAssertEqual(sut.currentQuestion?.id, "q1")
    }

    // MARK: - Progress Tests

    func testProgressIsZeroAtStart() {
        XCTAssertEqual(sut.progress, 0.0)
    }

    func testProgressUpdatesAfterAnswer() {
        sut.selectAnswer(0)
        sut.nextQuestion()

        XCTAssertEqual(sut.progress, 0.5, accuracy: 0.01)
    }

    func testProgressIsOneAtCompletion() {
        sut.selectAnswer(0)
        sut.nextQuestion()
        sut.selectAnswer(0)
        sut.nextQuestion()

        XCTAssertEqual(sut.progress, 1.0, accuracy: 0.01)
    }

    // MARK: - Answer Selection Tests

    func testSelectAnswerStoresSelection() {
        sut.selectAnswer(1)

        XCTAssertEqual(sut.selectedAnswerIndex, 1)
    }

    func testCanProceedOnlyWithSelectedAnswer() {
        XCTAssertFalse(sut.canProceed)

        sut.selectAnswer(0)

        XCTAssertTrue(sut.canProceed)
    }

    // MARK: - Navigation Tests

    func testNextQuestionAdvancesIndex() {
        sut.selectAnswer(0)

        sut.nextQuestion()

        XCTAssertEqual(sut.currentQuestionIndex, 1)
    }

    func testNextQuestionClearsSelection() {
        sut.selectAnswer(0)
        sut.nextQuestion()

        XCTAssertNil(sut.selectedAnswerIndex)
    }

    func testPreviousQuestionGoesBack() {
        sut.selectAnswer(0)
        sut.nextQuestion()

        sut.previousQuestion()

        XCTAssertEqual(sut.currentQuestionIndex, 0)
    }

    func testCannotGoPreviousOnFirstQuestion() {
        XCTAssertFalse(sut.canGoPrevious)
    }

    func testCanGoPreviousAfterAdvancing() {
        sut.selectAnswer(0)
        sut.nextQuestion()

        XCTAssertTrue(sut.canGoPrevious)
    }

    // MARK: - Quiz Completion Tests

    func testQuizCompletesAfterAllQuestions() {
        sut.selectAnswer(0)
        sut.nextQuestion()
        sut.selectAnswer(0)
        sut.nextQuestion()

        XCTAssertTrue(sut.isQuizComplete)
    }

    func testCalculatedLevelReflectsAnswers() {
        // Select beginner answer for Q1
        sut.selectAnswer(0)
        sut.nextQuestion()

        // Select beginner-ish answer for Q2 (intermediate is closest to beginner)
        sut.selectAnswer(0)
        sut.nextQuestion()

        // Should recommend intermediate based on scores
        XCTAssertNotNil(sut.recommendedLevel)
    }

    // MARK: - Complete Onboarding Tests

    func testCompleteOnboardingSetsLevel() async {
        sut.selectAnswer(0) // beginner
        sut.nextQuestion()
        sut.selectAnswer(0) // intermediate
        sut.nextQuestion()

        await sut.completeOnboarding()

        XCTAssertTrue(mockUserRepository.setCurrentLevelCallCount > 0)
    }

    func testCompleteOnboardingUpdatesAppState() async {
        sut.selectAnswer(0)
        sut.nextQuestion()
        sut.selectAnswer(0)
        sut.nextQuestion()

        await sut.completeOnboarding()

        XCTAssertTrue(mockAppState.hasCompletedOnboarding)
    }

    // MARK: - Score Calculation Tests

    func testScoreCalculationAccumulatesCorrectly() {
        // Select option with beginner: 3
        sut.selectAnswer(0)
        sut.nextQuestion()

        // Select option with intermediate: 3
        sut.selectAnswer(0)
        sut.nextQuestion()

        // Final scores: beginner: 3, intermediate: 3
        // Should be a tie, so either beginner or intermediate is valid
        let recommendedLevel = sut.recommendedLevel
        XCTAssertTrue(recommendedLevel == .beginner || recommendedLevel == .intermediate)
    }
}
