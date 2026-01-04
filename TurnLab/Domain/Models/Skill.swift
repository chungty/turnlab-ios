import Foundation

/// A ski skill with associated content and metadata.
/// Skills form the core educational content of Turn Lab.
struct Skill: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let level: SkillLevel
    let domains: [SkillDomain]
    let prerequisites: [String] // Skill IDs
    let summary: String
    let outcomeMilestones: OutcomeMilestones
    let assessmentContexts: [TerrainContext]
    let content: SkillContent

    /// Outcome milestone descriptions for each rating level.
    struct OutcomeMilestones: Codable, Hashable {
        let needsWork: String
        let developing: String
        let confident: String
        let mastered: String

        func description(for rating: Rating) -> String {
            switch rating {
            case .notAssessed: return "Not yet assessed"
            case .needsWork: return needsWork
            case .developing: return developing
            case .confident: return confident
            case .mastered: return mastered
            }
        }
    }

    /// Primary domain for display purposes
    var primaryDomain: SkillDomain {
        domains.first ?? .balance
    }

    /// Whether this skill is available without premium
    var isFree: Bool {
        level == .beginner
    }

    static func == (lhs: Skill, rhs: Skill) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
