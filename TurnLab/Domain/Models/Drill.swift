import Foundation

/// Practice drill with step-by-step instructions.
/// Drills are designed to be practiced on the mountain.
struct Drill: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let overview: String
    let steps: [DrillStep]
    let difficulty: DrillDifficulty
    let recommendedTerrain: [TerrainContext]
    let estimatedReps: String?

    struct DrillStep: Codable, Hashable, Identifiable {
        var id: String { "\(order)" }
        let order: Int
        let instruction: String
        let focusPoint: String?
    }

    enum DrillDifficulty: String, Codable {
        case easy
        case moderate
        case challenging

        var displayName: String {
            switch self {
            case .easy: return "Easy"
            case .moderate: return "Moderate"
            case .challenging: return "Challenging"
            }
        }
    }
}
