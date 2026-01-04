import Foundation

/// Represents the skill progression levels in Turn Lab.
/// Each level builds upon the previous, with increasing technical difficulty.
enum SkillLevel: Int, Codable, CaseIterable, Comparable {
    case beginner = 0
    case novice = 1
    case intermediate = 2
    case expert = 3

    var displayName: String {
        switch self {
        case .beginner: return "Beginner"
        case .novice: return "Novice"
        case .intermediate: return "Intermediate"
        case .expert: return "Expert"
        }
    }

    var description: String {
        switch self {
        case .beginner:
            return "Learning the fundamentals of skiing"
        case .novice:
            return "Building confidence on easy terrain"
        case .intermediate:
            return "Developing parallel technique"
        case .expert:
            return "Mastering advanced terrain and conditions"
        }
    }

    /// Whether this level requires premium unlock
    var requiresPremium: Bool {
        self != .beginner
    }

    /// Percentage of skills needed at "Confident" or above to unlock next level
    static let unlockThreshold: Double = 0.80

    static func < (lhs: SkillLevel, rhs: SkillLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
