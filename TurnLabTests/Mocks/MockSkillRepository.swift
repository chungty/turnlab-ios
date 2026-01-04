import Foundation
@testable import TurnLab

/// Mock implementation of SkillRepositoryProtocol for testing.
final class MockSkillRepository: SkillRepositoryProtocol {
    // MARK: - Configuration

    var skills: [Skill] = SkillFixtures.allTestSkills
    var quizQuestions: [QuizQuestion] = SkillFixtures.testQuizQuestions

    // MARK: - Call Tracking

    private(set) var getAllSkillsCalled = false
    private(set) var getSkillByIdCallCount = 0
    private(set) var lastRequestedSkillId: String?

    // MARK: - SkillRepositoryProtocol

    func getAllSkills() -> [Skill] {
        getAllSkillsCalled = true
        return skills
    }

    func getSkill(byId id: String) -> Skill? {
        getSkillByIdCallCount += 1
        lastRequestedSkillId = id
        return skills.first { $0.id == id }
    }

    func getSkills(for level: SkillLevel) -> [Skill] {
        return skills.filter { $0.level == level }
    }

    func getSkills(for domain: SkillDomain) -> [Skill] {
        return skills.filter { $0.domain == domain }
    }

    func getQuizQuestions() -> [QuizQuestion] {
        return quizQuestions
    }

    // MARK: - Test Helpers

    func reset() {
        getAllSkillsCalled = false
        getSkillByIdCallCount = 0
        lastRequestedSkillId = nil
    }
}
