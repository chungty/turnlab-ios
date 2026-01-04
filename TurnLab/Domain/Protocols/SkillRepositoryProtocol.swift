import Foundation

/// Protocol for accessing skill content data.
/// Skills are loaded from bundled JSON, not from Core Data.
@MainActor
protocol SkillRepositoryProtocol {
    /// Get all skills
    func getAllSkills() async -> [Skill]

    /// Get skills for a specific level
    func getSkills(for level: SkillLevel) async -> [Skill]

    /// Get skills for a specific domain
    func getSkills(for domain: SkillDomain) async -> [Skill]

    /// Get a specific skill by ID
    func getSkill(id: String) async -> Skill?

    /// Get prerequisite skills for a given skill
    func getPrerequisites(for skillId: String) async -> [Skill]

    /// Search skills by name or content
    func searchSkills(query: String) async -> [Skill]

    /// Get skills that are available (not locked by premium)
    func getAccessibleSkills(isPremium: Bool) async -> [Skill]
}
