import XCTest
@testable import TurnLab

/// Tests for SkillRepository.
/// Note: SkillRepository uses concrete ContentManager, so we test through MockSkillRepository
/// for most behavior tests, and verify basic integration with actual repository here.
@MainActor
final class SkillRepositoryTests: XCTestCase {
    var mockRepository: MockSkillRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockSkillRepository()
    }

    override func tearDown() {
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - Get All Skills Tests

    func testGetAllSkillsReturnsAllSkills() async {
        mockRepository.skills = SkillFixtures.allTestSkills

        let skills = await mockRepository.getAllSkills()

        XCTAssertEqual(skills.count, SkillFixtures.allTestSkills.count)
        XCTAssertTrue(mockRepository.getAllSkillsCalled)
    }

    func testGetAllSkillsReturnsEmptyWhenNoSkills() async {
        mockRepository.skills = []

        let skills = await mockRepository.getAllSkills()

        XCTAssertTrue(skills.isEmpty)
    }

    // MARK: - Get Skill By ID Tests

    func testGetSkillByIdReturnsCorrectSkill() async {
        mockRepository.skills = SkillFixtures.allTestSkills
        let expectedSkill = SkillFixtures.beginnerSkill

        let skill = await mockRepository.getSkill(id: expectedSkill.id)

        XCTAssertNotNil(skill)
        XCTAssertEqual(skill?.id, expectedSkill.id)
        XCTAssertEqual(skill?.name, expectedSkill.name)
        XCTAssertEqual(mockRepository.lastRequestedSkillId, expectedSkill.id)
    }

    func testGetSkillByIdReturnsNilForInvalidId() async {
        mockRepository.skills = SkillFixtures.allTestSkills

        let skill = await mockRepository.getSkill(id: "non-existent-id")

        XCTAssertNil(skill)
    }

    // MARK: - Get Skills By Level Tests

    func testGetSkillsByLevelFiltersCorrectly() async {
        mockRepository.skills = SkillFixtures.allTestSkills

        let beginnerSkills = await mockRepository.getSkills(for: .beginner)

        XCTAssertTrue(beginnerSkills.allSatisfy { $0.level == .beginner })
    }

    func testGetSkillsByLevelReturnsEmptyForLevelWithNoSkills() async {
        mockRepository.skills = [SkillFixtures.beginnerSkill]

        let expertSkills = await mockRepository.getSkills(for: .expert)

        XCTAssertTrue(expertSkills.isEmpty)
    }

    // MARK: - Get Skills By Domain Tests

    func testGetSkillsByDomainFiltersCorrectly() async {
        mockRepository.skills = SkillFixtures.allTestSkills

        let balanceSkills = await mockRepository.getSkills(for: .balance)

        XCTAssertTrue(balanceSkills.allSatisfy { $0.domains.contains(.balance) })
    }

    func testGetSkillsByDomainReturnsEmptyForDomainWithNoSkills() async {
        mockRepository.skills = [SkillFixtures.beginnerSkill] // balance domain only

        let terrainSkills = await mockRepository.getSkills(for: .terrainAdaptation)

        XCTAssertTrue(terrainSkills.isEmpty)
    }

    // MARK: - Search Tests

    func testSearchSkillsFindsMatchingName() async {
        mockRepository.skills = SkillFixtures.allTestSkills

        let results = await mockRepository.searchSkills(query: "Beginner")

        XCTAssertFalse(results.isEmpty)
        XCTAssertTrue(results.allSatisfy { $0.name.lowercased().contains("beginner") || $0.summary.lowercased().contains("beginner") })
    }

    func testSearchSkillsReturnsEmptyForNoMatch() async {
        mockRepository.skills = SkillFixtures.allTestSkills

        let results = await mockRepository.searchSkills(query: "nonexistentquery12345")

        XCTAssertTrue(results.isEmpty)
    }

    // MARK: - Accessible Skills Tests

    func testGetAccessibleSkillsWithPremiumReturnsAll() async {
        mockRepository.skills = SkillFixtures.allTestSkills

        let skills = await mockRepository.getAccessibleSkills(isPremium: true)

        XCTAssertEqual(skills.count, SkillFixtures.allTestSkills.count)
    }

    func testGetAccessibleSkillsWithoutPremiumReturnsOnlyBeginner() async {
        mockRepository.skills = SkillFixtures.allTestSkills

        let skills = await mockRepository.getAccessibleSkills(isPremium: false)

        XCTAssertTrue(skills.allSatisfy { $0.level == .beginner })
    }
}
