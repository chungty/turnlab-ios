import Foundation
import SwiftUI

/// Cross-cutting skill domains based on PSIA methodology.
/// Each skill can belong to one or more domains.
enum SkillDomain: String, Codable, CaseIterable, Identifiable {
    case balance = "balance"
    case edgeControl = "edge_control"
    case rotaryMovements = "rotary"
    case pressureManagement = "pressure"
    case terrainAdaptation = "terrain"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .balance: return "Balance & Stance"
        case .edgeControl: return "Edge Control"
        case .rotaryMovements: return "Rotary Movements"
        case .pressureManagement: return "Pressure Management"
        case .terrainAdaptation: return "Terrain Adaptation"
        }
    }

    var shortName: String {
        switch self {
        case .balance: return "Balance"
        case .edgeControl: return "Edges"
        case .rotaryMovements: return "Rotary"
        case .pressureManagement: return "Pressure"
        case .terrainAdaptation: return "Terrain"
        }
    }

    var description: String {
        switch self {
        case .balance:
            return "Body position, weight distribution, center of mass"
        case .edgeControl:
            return "Using ski edges to grip and shape turns"
        case .rotaryMovements:
            return "Steering and turning mechanics"
        case .pressureManagement:
            return "Weight transfer and ski loading"
        case .terrainAdaptation:
            return "Adjusting to conditions and terrain"
        }
    }

    var iconName: String {
        switch self {
        case .balance: return "figure.stand"
        case .edgeControl: return "angle"
        case .rotaryMovements: return "arrow.triangle.2.circlepath"
        case .pressureManagement: return "arrow.down.to.line"
        case .terrainAdaptation: return "mountain.2"
        }
    }

    var color: Color {
        switch self {
        case .balance: return .blue
        case .edgeControl: return .orange
        case .rotaryMovements: return .green
        case .pressureManagement: return .purple
        case .terrainAdaptation: return .brown
        }
    }
}
