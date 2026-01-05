import Foundation
@testable import TurnLab

/// Mock implementation of SkillRepositoryProtocol for testing.
@MainActor
final class MockSkillRepository: SkillRepositoryProtocol {
    // MARK: - Configuration

    var skills: [Skill] = SkillFixtures.allTestSkills

    // MARK: - Call Tracking

    private(set) var getAllSkillsCalled = false
    private(set) var getSkillByIdCallCount = 0
    private(set) var lastRequestedSkillId: String?

    // MARK: - SkillRepositoryProtocol

    func getAllSkills() async -> [Skill] {
        getAllSkillsCalled = true
        return skills
    }

    func getSkill(id: String) async -> Skill? {
        getSkillByIdCallCount += 1
        lastRequestedSkillId = id
        return skills.first { $0.id == id }
    }

    func getSkills(for level: SkillLevel) async -> [Skill] {
        return skills.filter { $0.level == level }
    }

    func getSkills(for domain: SkillDomain) async -> [Skill] {
        return skills.filter { $0.domains.contains(domain) }
    }

    func getPrerequisites(for skillId: String) async -> [Skill] {
        return []
    }

    func searchSkills(query: String) async -> [Skill] {
        let lowercasedQuery = query.lowercased()
        return skills.filter {
            $0.name.lowercased().contains(lowercasedQuery) ||
            $0.summary.lowercased().contains(lowercasedQuery)
        }
    }

    func getAccessibleSkills(isPremium: Bool) async -> [Skill] {
        if isPremium {
            return skills
        }
        return skills.filter { $0.level == .beginner }
    }

    // MARK: - Test Helpers

    func reset() {
        getAllSkillsCalled = false
        getSkillByIdCallCount = 0
        lastRequestedSkillId = nil
    }
}
