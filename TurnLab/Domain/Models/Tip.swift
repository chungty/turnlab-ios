import Foundation

/// Text-based instructional tip for a skill.
/// Tips can include mental cues, focus points, or detailed instructions.
struct Tip: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let content: String
    let category: TipCategory
    let isQuickReference: Bool

    enum TipCategory: String, Codable, CaseIterable {
        case mentalCue = "mental_cue"
        case bodyPosition = "body_position"
        case movement = "movement"
        case focus = "focus"
        case common_mistake = "common_mistake"

        var displayName: String {
            switch self {
            case .mentalCue: return "Mental Cue"
            case .bodyPosition: return "Body Position"
            case .movement: return "Movement"
            case .focus: return "Focus Point"
            case .common_mistake: return "Common Mistake"
            }
        }

        var iconName: String {
            switch self {
            case .mentalCue: return "brain.head.profile"
            case .bodyPosition: return "figure.stand"
            case .movement: return "arrow.left.and.right"
            case .focus: return "eye"
            case .common_mistake: return "exclamationmark.triangle"
            }
        }
    }
}
