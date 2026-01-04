import Foundation

/// Pre-run checklist for skill preparation.
/// Designed for quick on-mountain reference.
struct Checklist: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let items: [ChecklistItem]
    let purpose: ChecklistPurpose

    struct ChecklistItem: Codable, Hashable, Identifiable {
        var id: String { "\(order)" }
        let order: Int
        let text: String
        let isCritical: Bool
    }

    enum ChecklistPurpose: String, Codable {
        case preRun = "pre_run"
        case warmUp = "warm_up"
        case focusPoints = "focus_points"
        case safety = "safety"

        var displayName: String {
            switch self {
            case .preRun: return "Pre-Run"
            case .warmUp: return "Warm-Up"
            case .focusPoints: return "Focus Points"
            case .safety: return "Safety"
            }
        }
    }
}
