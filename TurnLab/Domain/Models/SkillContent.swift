import Foundation

/// Container for all content associated with a skill.
/// Content types are designed for different usage contexts.
struct SkillContent: Codable, Hashable {
    let videos: [VideoReference]
    let tips: [Tip]
    let drills: [Drill]
    let checklists: [Checklist]
    let warnings: [SafetyWarning]

    /// Primary video (first in list or explicitly marked)
    var primaryVideo: VideoReference? {
        videos.first(where: { $0.isPrimary }) ?? videos.first
    }

    /// Tips suitable for quick on-mountain reference
    var quickReferenceTips: [Tip] {
        tips.filter { $0.isQuickReference }
    }

    /// Mental cue tips only
    var mentalCues: [Tip] {
        tips.filter { $0.category == .mentalCue }
    }
}

/// Safety warning for a skill.
/// Integrated naturally into skill content.
struct SafetyWarning: Codable, Identifiable, Hashable {
    let id: String
    let title: String
    let content: String
    let severity: WarningSeverity
    let applicableContexts: [TerrainContext]

    enum WarningSeverity: String, Codable {
        case info
        case caution
        case warning

        var iconName: String {
            switch self {
            case .info: return "info.circle"
            case .caution: return "exclamationmark.triangle"
            case .warning: return "exclamationmark.octagon"
            }
        }
    }
}
