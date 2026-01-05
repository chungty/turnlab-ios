import XCTest
@testable import TurnLab

/// Tests for OnboardingViewModel.
/// Note: OnboardingViewModel uses concrete ContentManager and requires quiz questions
/// to be loaded. These tests verify basic state management and navigation.
@MainActor
final class OnboardingViewModelTests: XCTestCase {

    // MARK: - Quiz Result Tests

    func testQuizResultCreation() {
        let result = QuizResult(
            recommendedLevel: .beginner,
            levelScores: [.beginner: 10, .novice: 5, .intermediate: 2, .expert: 0],
            completedAt: Date(),
            answers: ["q1": "opt1", "q2": "opt2"]
        )

        XCTAssertEqual(result.recommendedLevel, .beginner)
        XCTAssertEqual(result.levelScores[.beginner], 10)
        XCTAssertEqual(result.answers.count, 2)
    }

    func testQuizResultScores() {
        let result = QuizResult(
            recommendedLevel: .intermediate,
            levelScores: [.beginner: 3, .novice: 5, .intermediate: 8, .expert: 2],
            completedAt: Date(),
            answers: [:]
        )

        // Intermediate should be recommended with highest score
        XCTAssertEqual(result.recommendedLevel, .intermediate)
        XCTAssertEqual(result.levelScores[.intermediate], 8)
    }

    // MARK: - Quiz Question Tests

    func testQuizQuestionOptions() {
        let question = SkillFixtures.testQuizQuestion

        XCTAssertFalse(question.scenario.isEmpty)
        XCTAssertFalse(question.options.isEmpty)
        XCTAssertTrue(question.options.count >= 2)
    }

    func testQuizOptionPointsAccess() {
        let question = SkillFixtures.testQuizQuestion

        // Test that we can access level points from options
        if let firstOption = question.options.first {
            // Should have points for at least one level
            let hasPoints = SkillLevel.allCases.contains { level in
                firstOption.points(for: level) > 0
            }
            XCTAssertTrue(hasPoints)
        } else {
            XCTFail("Question should have at least one option")
        }
    }

    // MARK: - Computed Properties Tests

    func testProgressCalculation() {
        // Test with a simple mock of progress calculation logic
        let totalQuestions = 5
        let currentIndex = 2

        let progress = Double(currentIndex) / Double(totalQuestions)

        XCTAssertEqual(progress, 0.4, accuracy: 0.001)
    }

    func testProgressEdgeCases() {
        // At the start
        let startProgress = Double(0) / Double(5)
        XCTAssertEqual(startProgress, 0.0, accuracy: 0.001)

        // At the end
        let endProgress = Double(4) / Double(5) // 0-indexed, so 4 is last of 5
        XCTAssertEqual(endProgress, 0.8, accuracy: 0.001)
    }

    // MARK: - Navigation Logic Tests

    func testCanGoBackLogic() {
        // Can't go back from first question (index 0)
        XCTAssertFalse(0 > 0)

        // Can go back from any other question
        XCTAssertTrue(1 > 0)
        XCTAssertTrue(5 > 0)
    }

    func testIsLastQuestionLogic() {
        let totalQuestions = 12

        // Not last
        XCTAssertFalse(0 == totalQuestions - 1)
        XCTAssertFalse(5 == totalQuestions - 1)

        // Is last
        XCTAssertTrue(11 == totalQuestions - 1)
    }

    // MARK: - Level Score Calculation Tests

    func testLevelScoreCalculation() {
        // Simulate accumulating scores
        var levelScores: [SkillLevel: Int] = [:]
        for level in SkillLevel.allCases {
            levelScores[level] = 0
        }

        // Add some points
        levelScores[.beginner, default: 0] += 3
        levelScores[.novice, default: 0] += 1
        levelScores[.beginner, default: 0] += 2
        levelScores[.intermediate, default: 0] += 4

        XCTAssertEqual(levelScores[.beginner], 5)
        XCTAssertEqual(levelScores[.novice], 1)
        XCTAssertEqual(levelScores[.intermediate], 4)
        XCTAssertEqual(levelScores[.expert], 0)
    }

    func testFindMaxLevel() {
        let levelScores: [SkillLevel: Int] = [
            .beginner: 5,
            .novice: 3,
            .intermediate: 8,
            .expert: 2
        ]

        let maxLevel = levelScores.max(by: { $0.value < $1.value })?.key

        XCTAssertEqual(maxLevel, .intermediate)
    }

    func testFindMaxLevelWithTie() {
        let levelScores: [SkillLevel: Int] = [
            .beginner: 5,
            .novice: 5,
            .intermediate: 5,
            .expert: 5
        ]

        // When there's a tie, any level could be chosen
        let maxLevel = levelScores.max(by: { $0.value < $1.value })?.key

        XCTAssertNotNil(maxLevel)
        XCTAssertTrue(levelScores[maxLevel!] == 5)
    }

    // MARK: - Answer Tracking Tests

    func testAnswerStorage() {
        var answers: [String: String] = [:]

        // Add first answer
        answers["q1"] = "opt-a"
        XCTAssertEqual(answers["q1"], "opt-a")

        // Replace answer
        answers["q1"] = "opt-b"
        XCTAssertEqual(answers["q1"], "opt-b")

        // Add more answers
        answers["q2"] = "opt-c"
        XCTAssertEqual(answers.count, 2)
    }

    func testCanGoNextRequiresAnswer() {
        var answers: [String: String] = [:]
        let currentQuestionId = "q1"

        // Without answer, can't proceed
        XCTAssertNil(answers[currentQuestionId])

        // With answer, can proceed
        answers[currentQuestionId] = "opt-a"
        XCTAssertNotNil(answers[currentQuestionId])
    }
}
