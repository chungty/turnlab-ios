import XCTest
@testable import TurnLab

final class ProgressionServiceTests: XCTestCase {
    var sut: ProgressionService!
    var mockSkillRepository: MockSkillRepository!
    var mockAssessmentRepository: MockAssessmentRepository!

    @MainActor
    override func setUp() {
        super.setUp()
        mockSkillRepository = MockSkillRepository()
        mockAssessmentRepository = MockAssessmentRepository()
        sut = ProgressionService(
            skillRepository: mockSkillRepository,
            assessmentRepository: mockAssessmentRepository
        )
    }

    override func tearDown() {
        sut = nil
        mockSkillRepository = nil
        mockAssessmentRepository = nil
        super.tearDown()
    }

    // MARK: - Level Progress Tests

    @MainActor
    func testProgressTowardNextLevelWithNoAssessments() async {
        mockAssessmentRepository.skillRatings = [:]

        let progress = await sut.progressTowardNextLevel(currentLevel: .beginner)

        XCTAssertEqual(progress, 0.0)
    }

    @MainActor
    func testProgressTowardNextLevelWithAllConfident() async {
        // Set up all beginner skills as confident
        let beginnerSkills = await mockSkillRepository.getSkills(for: .beginner)
        var ratings: [String: Rating] = [:]
        for skill in beginnerSkills {
            ratings[skill.id] = .confident
        }
        mockAssessmentRepository.skillRatings = ratings

        let progress = await sut.progressTowardNextLevel(currentLevel: .beginner)

        // All skills at confident should give high progress
        XCTAssertGreaterThan(progress, 0.7)
    }

    // MARK: - Level Advancement Tests

    @MainActor
    func testCanAdvanceToNextLevelWhenNotReady() async {
        mockAssessmentRepository.skillRatings = [:]

        let canAdvance = await sut.canAdvanceToNextLevel(currentLevel: .beginner)

        XCTAssertFalse(canAdvance)
    }

    @MainActor
    func testCannotAdvanceBeyondExpert() async {
        // Expert has no next level
        let nextLevel = sut.nextLevel(from: .expert)

        XCTAssertNil(nextLevel)
    }

    // MARK: - Next Level Tests

    func testNextLevelFromBeginner() {
        XCTAssertEqual(sut.nextLevel(from: .beginner), .novice)
    }

    func testNextLevelFromNovice() {
        XCTAssertEqual(sut.nextLevel(from: .novice), .intermediate)
    }

    func testNextLevelFromIntermediate() {
        XCTAssertEqual(sut.nextLevel(from: .intermediate), .expert)
    }

    func testNextLevelFromExpert() {
        XCTAssertNil(sut.nextLevel(from: .expert))
    }

    // MARK: - Overall Rating Tests

    @MainActor
    func testOverallRatingForSkill() async {
        mockAssessmentRepository.skillRatings = ["test-skill": .confident]

        let rating = await sut.overallRating(for: "test-skill")

        XCTAssertEqual(rating, .confident)
    }

    @MainActor
    func testOverallRatingWhenNoAssessments() async {
        mockAssessmentRepository.skillRatings = [:]

        let rating = await sut.overallRating(for: "unknown-skill")

        XCTAssertEqual(rating, .notAssessed)
    }

    // MARK: - Suggested Skills Tests

    @MainActor
    func testSuggestedSkillsReturnsLimit() async {
        mockSkillRepository.skills = SkillFixtures.allTestSkills

        let suggested = await sut.suggestedSkills(currentLevel: .beginner, limit: 2)

        XCTAssertLessThanOrEqual(suggested.count, 2)
    }

    @MainActor
    func testSuggestedSkillsPrioritizesUnassessed() async {
        mockSkillRepository.skills = SkillFixtures.allTestSkills

        // Mark one skill as confident
        mockAssessmentRepository.skillRatings = ["test-beginner-skill": .confident]

        let suggested = await sut.suggestedSkills(currentLevel: .beginner, limit: 3)

        // Unassessed skills should come first
        if let firstSuggested = suggested.first {
            // First suggested should not be the confident one
            XCTAssertNotEqual(firstSuggested.id, "test-beginner-skill")
        }
    }
}
