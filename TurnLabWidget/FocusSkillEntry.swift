import WidgetKit

/// Widget timeline entry containing focus skill data.
struct FocusSkillEntry: TimelineEntry {
    let date: Date
    let skillId: String?
    let skillName: String
    let skillLevel: String
    let levelColor: String
    let progress: Double
    let nextMilestone: String?
    let domain: String
    let domainIcon: String

    /// URL for deep linking when widget is tapped.
    var widgetURL: URL? {
        guard let skillId = skillId else { return nil }
        return URL(string: "turnlab://skill?id=\(skillId)")
    }

    /// Placeholder entry for widget preview.
    static var placeholder: FocusSkillEntry {
        FocusSkillEntry(
            date: Date(),
            skillId: "basic-stance",
            skillName: "Basic Athletic Stance",
            skillLevel: "Beginner",
            levelColor: "green",
            progress: 0.65,
            nextMilestone: "Feel pressure on the whole foot",
            domain: "Balance",
            domainIcon: "figure.stand"
        )
    }

    /// Snapshot entry for widget gallery.
    static var snapshot: FocusSkillEntry {
        placeholder
    }

    /// Empty state entry when no focus skill is set.
    static var empty: FocusSkillEntry {
        FocusSkillEntry(
            date: Date(),
            skillId: nil,
            skillName: "No Focus Skill",
            skillLevel: "Set Up",
            levelColor: "gray",
            progress: 0,
            nextMilestone: "Tap to choose a skill to focus on",
            domain: "Turn Lab",
            domainIcon: "skis.fill"
        )
    }
}
