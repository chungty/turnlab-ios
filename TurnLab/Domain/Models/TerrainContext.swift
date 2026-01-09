import Foundation

/// Terrain context for contextual skill assessments.
/// Skills can be assessed differently based on terrain conditions.
enum TerrainContext: String, Codable, CaseIterable, Identifiable {
    case groomedGreen = "groomed_green"
    case groomedBlue = "groomed_blue"
    case groomedBlack = "groomed_black"
    case bumps = "bumps"
    case powder = "powder"
    case steeps = "steeps"
    case ice = "ice"
    case crud = "crud"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .groomedGreen: return "Groomed Green"
        case .groomedBlue: return "Groomed Blue"
        case .groomedBlack: return "Groomed Black"
        case .bumps: return "Bumps/Moguls"
        case .powder: return "Powder"
        case .steeps: return "Steeps (>25°)"
        case .ice: return "Icy Conditions"
        case .crud: return "Variable/Crud"
        }
    }

    var shortName: String {
        switch self {
        case .groomedGreen: return "Green"
        case .groomedBlue: return "Blue"
        case .groomedBlack: return "Black"
        case .bumps: return "Bumps"
        case .powder: return "Powder"
        case .steeps: return "Steeps"
        case .ice: return "Ice"
        case .crud: return "Crud"
        }
    }

    var iconName: String {
        switch self {
        case .groomedGreen: return "circle.fill"
        case .groomedBlue: return "square.fill"
        case .groomedBlack: return "diamond.fill"
        case .bumps: return "waveform"
        case .powder: return "snowflake"
        case .steeps: return "arrow.down.right"
        case .ice: return "thermometer.snowflake"
        case .crud: return "cloud.snow"
        }
    }

    /// Stable index for Core Data storage (order-based on CaseIterable)
    var stableIndex: Int {
        Self.allCases.firstIndex(of: self)!
    }

    /// Initialize from stable index
    static func from(stableIndex: Int) -> TerrainContext? {
        guard stableIndex >= 0 && stableIndex < allCases.count else { return nil }
        return allCases[stableIndex]
    }

    /// Difficulty weight for this terrain context
    var difficultyWeight: Double {
        switch self {
        case .groomedGreen: return 1.0
        case .groomedBlue: return 1.5
        case .groomedBlack: return 2.0
        case .bumps: return 2.5
        case .powder: return 2.5
        case .steeps: return 3.0
        case .ice: return 2.0
        case .crud: return 2.0
        }
    }
}
