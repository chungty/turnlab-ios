import Foundation

/// Represents the skill progression levels in Turn Lab.
/// Each level builds upon the previous, with increasing technical difficulty.
enum SkillLevel: String, Codable, CaseIterable, Comparable {
    case beginner = "beginner"
    case novice = "novice"
    case intermediate = "intermediate"
    case expert = "expert"

    /// Integer representation for Core Data storage and comparison
    var order: Int {
        switch self {
        case .beginner: return 0
        case .novice: return 1
        case .intermediate: return 2
        case .expert: return 3
        }
    }

    /// Initialize from integer value (for Core Data)
    init?(rawValue: Int) {
        switch rawValue {
        case 0: self = .beginner
        case 1: self = .novice
        case 2: self = .intermediate
        case 3: self = .expert
        default: return nil
        }
    }

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
        lhs.order < rhs.order
    }
}
