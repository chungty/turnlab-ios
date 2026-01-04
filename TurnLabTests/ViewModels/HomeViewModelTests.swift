import XCTest
@testable import TurnLab

@MainActor
final class HomeViewModelTests: XCTestCase {
    var sut: HomeViewModel!
    var mockSkillRepository: MockSkillRepository!
    var mockUserRepository: MockUserRepository!
    var mockAssessmentRepository: MockAssessmentRepository!
    var mockProgressionService: MockProgressionService!
    var mockPremiumManager: MockPremiumManager!

    override func setUp() {
        super.setUp()
        mockSkillRepository = MockSkillRepository()
        mockUserRepository = MockUserRepository()
        mockAssessmentRepository = MockAssessmentRepository()
        mockProgressionService = MockProgressionService()
        mockPremiumManager = MockPremiumManager()

        sut = HomeViewModel(
            skillRepository: mockSkillRepository,
            userRepository: mockUserRepository,
            assessmentRepository: mockAssessmentRepository,
            progressionService: mockProgressionService,
            premiumManager: mockPremiumManager
        )
    }

    override func tearDown() {
        sut = nil
        mockSkillRepository = nil
        mockUserRepository = nil
        mockAssessmentRepository = nil
        mockProgressionService = nil
        mockPremiumManager = nil
        super.tearDown()
    }

    // MARK: - Initial State Tests

    func testInitialStateHasNoData() {
        XCTAssertNil(sut.focusSkill)
        XCTAssertTrue(sut.suggestedSkills.isEmpty)
    }

    // MARK: - Load Data Tests

    func testLoadDataSetsFocusSkill() async {
        mockUserRepository.focusSkillId = "test-beginner-skill"
        mockSkillRepository.skills = SkillFixtures.allTestSkills

        await sut.loadData()

        XCTAssertNotNil(sut.focusSkill)
        XCTAssertEqual(sut.focusSkill?.id, "test-beginner-skill")
    }

    func testLoadDataSetsCurrentLevel() async {
        mockUserRepository.currentLevel = .intermediate

        await sut.loadData()

        XCTAssertEqual(sut.currentLevel, .intermediate)
    }

    func testLoadDataPopulatesSuggestedSkills() async {
        mockUserRepository.currentLevel = .beginner
        mockSkillRepository.skills = SkillFixtures.allTestSkills

        await sut.loadData()

        XCTAssertFalse(sut.suggestedSkills.isEmpty)
    }

    func testLoadDataCalculatesLevelProgress() async {
        mockUserRepository.currentLevel = .beginner
        mockSkillRepository.skills = SkillFixtures.allTestSkills
        mockProgressionService.levelProgress = 0.5

        await sut.loadData()

        XCTAssertEqual(sut.currentLevelProgress, 0.5, accuracy: 0.01)
    }

    // MARK: - Focus Skill Tests

    func testSetFocusSkillUpdatesRepository() async {
        let skill = SkillFixtures.beginnerSkill

        await sut.setFocusSkill(skill)

        XCTAssertEqual(mockUserRepository.focusSkillId, skill.id)
        XCTAssertEqual(sut.focusSkill?.id, skill.id)
    }

    func testClearFocusSkillRemovesFocus() async {
        let skill = SkillFixtures.beginnerSkill
        await sut.setFocusSkill(skill)

        await sut.clearFocusSkill()

        XCTAssertNil(mockUserRepository.focusSkillId)
        XCTAssertNil(sut.focusSkill)
    }

    // MARK: - Premium Tests

    func testIsPremiumReflectsManager() async {
        mockPremiumManager.isPremium = true

        await sut.loadData()

        XCTAssertTrue(sut.isPremium)
    }

    func testLockedSkillsRequirePremium() async {
        mockPremiumManager.isPremium = false
        mockUserRepository.currentLevel = .beginner
        mockSkillRepository.skills = SkillFixtures.allTestSkills

        await sut.loadData()

        // Novice and above skills should be locked
        let noviceSkill = SkillFixtures.noviceSkill
        XCTAssertTrue(sut.isSkillLocked(noviceSkill))

        // Beginner skills should not be locked
        let beginnerSkill = SkillFixtures.beginnerSkill
        XCTAssertFalse(sut.isSkillLocked(beginnerSkill))
    }
}

// MARK: - Mock Progression Service

final class MockProgressionService {
    var levelProgress: Double = 0.0
    var canAdvance: Bool = false

    func calculateLevelProgress(for level: SkillLevel, skills: [Skill]) -> Double {
        return levelProgress
    }

    func canAdvanceLevel(from level: SkillLevel, skills: [Skill]) -> Bool {
        return canAdvance
    }
}

// MARK: - Mock Premium Manager

final class MockPremiumManager {
    var isPremium: Bool = false

    func checkPremiumStatus() -> Bool {
        return isPremium
    }
}
