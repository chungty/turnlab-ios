import XCTest
@testable import TurnLab

final class SkillRepositoryTests: XCTestCase {
    var sut: SkillRepository!
    var mockContentManager: MockContentManager!

    override func setUp() {
        super.setUp()
        mockContentManager = MockContentManager()
        sut = SkillRepository(contentManager: mockContentManager)
    }

    override func tearDown() {
        sut = nil
        mockContentManager = nil
        super.tearDown()
    }

    // MARK: - Get All Skills Tests

    func testGetAllSkillsReturnsAllSkills() {
        mockContentManager.skills = SkillFixtures.allTestSkills

        let skills = sut.getAllSkills()

        XCTAssertEqual(skills.count, SkillFixtures.allTestSkills.count)
    }

    func testGetAllSkillsReturnsEmptyWhenNoSkills() {
        mockContentManager.skills = []

        let skills = sut.getAllSkills()

        XCTAssertTrue(skills.isEmpty)
    }

    // MARK: - Get Skill By ID Tests

    func testGetSkillByIdReturnsCorrectSkill() {
        mockContentManager.skills = SkillFixtures.allTestSkills
        let expectedSkill = SkillFixtures.beginnerSkill

        let skill = sut.getSkill(byId: expectedSkill.id)

        XCTAssertNotNil(skill)
        XCTAssertEqual(skill?.id, expectedSkill.id)
        XCTAssertEqual(skill?.name, expectedSkill.name)
    }

    func testGetSkillByIdReturnsNilForInvalidId() {
        mockContentManager.skills = SkillFixtures.allTestSkills

        let skill = sut.getSkill(byId: "non-existent-id")

        XCTAssertNil(skill)
    }

    // MARK: - Get Skills By Level Tests

    func testGetSkillsByLevelFiltersCorrectly() {
        mockContentManager.skills = SkillFixtures.allTestSkills

        let beginnerSkills = sut.getSkills(for: .beginner)

        XCTAssertTrue(beginnerSkills.allSatisfy { $0.level == .beginner })
    }

    func testGetSkillsByLevelReturnsEmptyForLevelWithNoSkills() {
        mockContentManager.skills = [SkillFixtures.beginnerSkill]

        let expertSkills = sut.getSkills(for: .expert)

        XCTAssertTrue(expertSkills.isEmpty)
    }

    // MARK: - Get Skills By Domain Tests

    func testGetSkillsByDomainFiltersCorrectly() {
        mockContentManager.skills = SkillFixtures.allTestSkills

        let balanceSkills = sut.getSkills(for: .balance)

        XCTAssertTrue(balanceSkills.allSatisfy { $0.domain == .balance })
    }

    func testGetSkillsByDomainReturnsEmptyForDomainWithNoSkills() {
        mockContentManager.skills = [SkillFixtures.beginnerSkill] // balance domain

        let terrainSkills = sut.getSkills(for: .terrainAdaptation)

        XCTAssertTrue(terrainSkills.isEmpty)
    }

    // MARK: - Get Quiz Questions Tests

    func testGetQuizQuestionsReturnsQuestions() {
        mockContentManager.quizQuestions = SkillFixtures.testQuizQuestions

        let questions = sut.getQuizQuestions()

        XCTAssertEqual(questions.count, SkillFixtures.testQuizQuestions.count)
    }
}

// MARK: - Mock Content Manager

final class MockContentManager {
    var skills: [Skill] = []
    var quizQuestions: [QuizQuestion] = []

    func getAllSkills() -> [Skill] {
        return skills
    }

    func skill(byId id: String) -> Skill? {
        return skills.first { $0.id == id }
    }

    func skills(for level: SkillLevel) -> [Skill] {
        return skills.filter { $0.level == level }
    }

    func skills(for domain: SkillDomain) -> [Skill] {
        return skills.filter { $0.domain == domain }
    }

    func getQuizQuestions() -> [QuizQuestion] {
        return quizQuestions
    }
}
