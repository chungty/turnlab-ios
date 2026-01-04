import XCTest
@testable import TurnLab

final class ProgressionServiceTests: XCTestCase {
    var sut: ProgressionService!
    var mockUserRepository: MockUserRepository!
    var mockAssessmentRepository: MockAssessmentRepository!

    override func setUp() {
        super.setUp()
        mockUserRepository = MockUserRepository()
        mockAssessmentRepository = MockAssessmentRepository()
        sut = ProgressionService(
            userRepository: mockUserRepository,
            assessmentRepository: mockAssessmentRepository
        )
    }

    override func tearDown() {
        sut = nil
        mockUserRepository = nil
        mockAssessmentRepository = nil
        super.tearDown()
    }

    // MARK: - Level Progression Tests

    func testGetCurrentLevel() {
        mockUserRepository.currentLevel = .intermediate

        let level = sut.getCurrentLevel()

        XCTAssertEqual(level, .intermediate)
        XCTAssertTrue(mockUserRepository.getCurrentLevelCalled)
    }

    func testSetCurrentLevel() {
        sut.setCurrentLevel(.expert)

        XCTAssertEqual(mockUserRepository.currentLevel, .expert)
        XCTAssertEqual(mockUserRepository.setCurrentLevelCallCount, 1)
        XCTAssertEqual(mockUserRepository.lastSetLevel, .expert)
    }

    // MARK: - Progress Calculation Tests

    func testCalculateLevelProgressWithNoAssessments() {
        let skills = SkillFixtures.allTestSkills.filter { $0.level == .beginner }
        mockAssessmentRepository.assessments = []

        let progress = sut.calculateLevelProgress(for: .beginner, skills: skills)

        XCTAssertEqual(progress, 0.0)
    }

    func testCalculateLevelProgressWithAllMastered() {
        let skills = [SkillFixtures.beginnerSkill]
        mockAssessmentRepository.assessments = [
            createAssessment(skillId: skills[0].id, rating: .mastered)
        ]

        let progress = sut.calculateLevelProgress(for: .beginner, skills: skills)

        XCTAssertEqual(progress, 1.0)
    }

    func testCalculateLevelProgressPartial() {
        let skills = [SkillFixtures.beginnerSkill, SkillFixtures.beginnerSkill]
        // Create two skills with same level but different IDs
        let skill1 = Skill(
            id: "skill-1",
            name: "Skill 1",
            level: .beginner,
            domain: .balance,
            description: "Test",
            whyItMatters: "Test",
            milestones: [],
            content: SkillFixtures.basicContent
        )
        let skill2 = Skill(
            id: "skill-2",
            name: "Skill 2",
            level: .beginner,
            domain: .balance,
            description: "Test",
            whyItMatters: "Test",
            milestones: [],
            content: SkillFixtures.basicContent
        )

        mockAssessmentRepository.assessments = [
            createAssessment(skillId: "skill-1", rating: .confident),
            createAssessment(skillId: "skill-2", rating: .developing)
        ]

        let progress = sut.calculateLevelProgress(for: .beginner, skills: [skill1, skill2])

        // confident = 0.75, developing = 0.5, average = 0.625
        XCTAssertEqual(progress, 0.625, accuracy: 0.01)
    }

    // MARK: - Skill Progress Tests

    func testCalculateSkillProgressFromRating() {
        XCTAssertEqual(sut.progressValue(for: .needsWork), 0.25, accuracy: 0.01)
        XCTAssertEqual(sut.progressValue(for: .developing), 0.5, accuracy: 0.01)
        XCTAssertEqual(sut.progressValue(for: .confident), 0.75, accuracy: 0.01)
        XCTAssertEqual(sut.progressValue(for: .mastered), 1.0, accuracy: 0.01)
    }

    // MARK: - Level Up Eligibility Tests

    func testCanAdvanceLevelWhenNotReady() {
        let skills = [SkillFixtures.beginnerSkill]
        mockAssessmentRepository.assessments = [
            createAssessment(skillId: skills[0].id, rating: .developing)
        ]

        let canAdvance = sut.canAdvanceLevel(from: .beginner, skills: skills)

        XCTAssertFalse(canAdvance)
    }

    func testCanAdvanceLevelWhenReady() {
        let skills = [SkillFixtures.beginnerSkill]
        mockAssessmentRepository.assessments = [
            createAssessment(skillId: skills[0].id, rating: .confident)
        ]

        let canAdvance = sut.canAdvanceLevel(from: .beginner, skills: skills)

        XCTAssertTrue(canAdvance)
    }

    func testCannotAdvanceBeyondExpert() {
        let canAdvance = sut.canAdvanceLevel(from: .expert, skills: [])

        XCTAssertFalse(canAdvance)
    }

    // MARK: - Helpers

    private func createAssessment(skillId: String, rating: Rating) -> Assessment {
        Assessment(
            id: UUID(),
            skillId: skillId,
            context: .groomed,
            rating: rating,
            date: Date(),
            notes: nil
        )
    }
}

// MARK: - Mock Assessment Repository

final class MockAssessmentRepository: AssessmentRepositoryProtocol {
    var assessments: [Assessment] = []

    func getAllAssessments() -> [Assessment] {
        return assessments
    }

    func getAssessments(for skillId: String) -> [Assessment] {
        return assessments.filter { $0.skillId == skillId }
    }

    func getLatestAssessment(for skillId: String) -> Assessment? {
        return getAssessments(for: skillId)
            .sorted { $0.date > $1.date }
            .first
    }

    func saveAssessment(_ assessment: Assessment) {
        assessments.append(assessment)
    }

    func deleteAssessment(_ assessment: Assessment) {
        assessments.removeAll { $0.id == assessment.id }
    }
}
