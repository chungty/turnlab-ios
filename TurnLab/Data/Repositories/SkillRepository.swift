import Foundation

/// Implementation of SkillRepositoryProtocol using ContentManager.
@MainActor
final class SkillRepository: SkillRepositoryProtocol {
    private let contentManager: ContentManager

    init(contentManager: ContentManager) {
        self.contentManager = contentManager
    }

    func getAllSkills() async -> [Skill] {
        contentManager.skills
    }

    func getSkills(for level: SkillLevel) async -> [Skill] {
        contentManager.skills.filter { $0.level == level }
    }

    func getSkills(for domain: SkillDomain) async -> [Skill] {
        contentManager.skills.filter { $0.domains.contains(domain) }
    }

    func getSkill(id: String) async -> Skill? {
        contentManager.skills.first { $0.id == id }
    }

    func getPrerequisites(for skillId: String) async -> [Skill] {
        guard let skill = await getSkill(id: skillId) else { return [] }
        return contentManager.skills.filter { skill.prerequisites.contains($0.id) }
    }

    func searchSkills(query: String) async -> [Skill] {
        let lowercasedQuery = query.lowercased()
        return contentManager.skills.filter { skill in
            skill.name.lowercased().contains(lowercasedQuery) ||
            skill.summary.lowercased().contains(lowercasedQuery) ||
            skill.content.tips.contains { $0.content.lowercased().contains(lowercasedQuery) }
        }
    }

    func getAccessibleSkills(isPremium: Bool) async -> [Skill] {
        if isPremium {
            return contentManager.skills
        }
        return contentManager.skills.filter { $0.isFree }
    }
}
