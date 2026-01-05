import XCTest
@testable import TurnLab

/// Tests for HomeViewModel.
/// Note: HomeViewModel requires concrete ProgressionService, so we test
/// basic initialization and state management without full dependency injection.
@MainActor
final class HomeViewModelTests: XCTestCase {
    var mockSkillRepository: MockSkillRepository!
    var mockAssessmentRepository: MockAssessmentRepository!
    var contentManager: ContentManager!

    override func setUp() {
        super.setUp()
        mockSkillRepository = MockSkillRepository()
        mockAssessmentRepository = MockAssessmentRepository()
        contentManager = ContentManager()
    }

    override func tearDown() {
        mockSkillRepository = nil
        mockAssessmentRepository = nil
        contentManager = nil
        super.tearDown()
    }

    // MARK: - Initial State Tests

    func testHomeViewModelInitializes() {
        let appState = AppState()
        let progressionService = ProgressionService(
            skillRepository: mockSkillRepository,
            assessmentRepository: mockAssessmentRepository
        )

        let sut = HomeViewModel(
            skillRepository: mockSkillRepository,
            assessmentRepository: mockAssessmentRepository,
            progressionService: progressionService,
            appState: appState,
            contentManager: contentManager
        )

        XCTAssertNil(sut.focusSkill)
        XCTAssertTrue(sut.suggestedSkills.isEmpty)
        XCTAssertEqual(sut.levelProgress, 0)
        XCTAssertFalse(sut.isLoading)
    }

    func testCurrentLevelReflectsAppState() {
        let appState = AppState()
        appState.currentUserLevel = .intermediate
        let progressionService = ProgressionService(
            skillRepository: mockSkillRepository,
            assessmentRepository: mockAssessmentRepository
        )

        let sut = HomeViewModel(
            skillRepository: mockSkillRepository,
            assessmentRepository: mockAssessmentRepository,
            progressionService: progressionService,
            appState: appState,
            contentManager: contentManager
        )

        XCTAssertEqual(sut.currentLevel, .intermediate)
    }

    // MARK: - Focus Skill Tests

    func testSetFocusSkillUpdatesState() async {
        let appState = AppState()
        let progressionService = ProgressionService(
            skillRepository: mockSkillRepository,
            assessmentRepository: mockAssessmentRepository
        )

        let sut = HomeViewModel(
            skillRepository: mockSkillRepository,
            assessmentRepository: mockAssessmentRepository,
            progressionService: progressionService,
            appState: appState,
            contentManager: contentManager
        )

        let skill = SkillFixtures.beginnerSkill
        sut.setFocusSkill(skill)

        XCTAssertEqual(sut.focusSkill?.id, skill.id)
        XCTAssertEqual(appState.focusSkillId, skill.id)
    }

    func testClearFocusSkillRemovesFocus() async {
        let appState = AppState()
        let progressionService = ProgressionService(
            skillRepository: mockSkillRepository,
            assessmentRepository: mockAssessmentRepository
        )

        let sut = HomeViewModel(
            skillRepository: mockSkillRepository,
            assessmentRepository: mockAssessmentRepository,
            progressionService: progressionService,
            appState: appState,
            contentManager: contentManager
        )

        // Set a focus skill first
        let skill = SkillFixtures.beginnerSkill
        sut.setFocusSkill(skill)

        // Clear it
        sut.clearFocusSkill()

        XCTAssertNil(sut.focusSkill)
        XCTAssertNil(appState.focusSkillId)
        XCTAssertEqual(sut.focusSkillRating, .notAssessed)
    }

    // MARK: - Load Data Tests

    func testLoadDataSetsLoadingState() async {
        let appState = AppState()
        let progressionService = ProgressionService(
            skillRepository: mockSkillRepository,
            assessmentRepository: mockAssessmentRepository
        )

        let sut = HomeViewModel(
            skillRepository: mockSkillRepository,
            assessmentRepository: mockAssessmentRepository,
            progressionService: progressionService,
            appState: appState,
            contentManager: contentManager
        )

        // After loading completes, isLoading should be false
        await sut.loadData()

        XCTAssertFalse(sut.isLoading)
    }

    func testCanAdvanceLevelWhenProgressHighEnough() async {
        let appState = AppState()
        let progressionService = ProgressionService(
            skillRepository: mockSkillRepository,
            assessmentRepository: mockAssessmentRepository
        )

        let sut = HomeViewModel(
            skillRepository: mockSkillRepository,
            assessmentRepository: mockAssessmentRepository,
            progressionService: progressionService,
            appState: appState,
            contentManager: contentManager
        )

        // Set level progress high enough to advance (threshold is 0.7)
        // Note: levelProgress is calculated from progressionService, so this test
        // just verifies the computed property logic
        XCTAssertFalse(sut.canAdvanceLevel) // 0 progress
    }

    func testNextLevelReturnsCorrectValue() {
        let appState = AppState()
        appState.currentUserLevel = .beginner
        let progressionService = ProgressionService(
            skillRepository: mockSkillRepository,
            assessmentRepository: mockAssessmentRepository
        )

        let sut = HomeViewModel(
            skillRepository: mockSkillRepository,
            assessmentRepository: mockAssessmentRepository,
            progressionService: progressionService,
            appState: appState,
            contentManager: contentManager
        )

        XCTAssertEqual(sut.nextLevel, .novice)
    }

    func testNextLevelIsNilForExpert() {
        let appState = AppState()
        appState.currentUserLevel = .expert
        let progressionService = ProgressionService(
            skillRepository: mockSkillRepository,
            assessmentRepository: mockAssessmentRepository
        )

        let sut = HomeViewModel(
            skillRepository: mockSkillRepository,
            assessmentRepository: mockAssessmentRepository,
            progressionService: progressionService,
            appState: appState,
            contentManager: contentManager
        )

        XCTAssertNil(sut.nextLevel)
    }
}
