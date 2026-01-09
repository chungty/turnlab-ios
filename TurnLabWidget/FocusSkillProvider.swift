import WidgetKit
import SwiftUI

/// Timeline provider for the focus skill widget.
struct FocusSkillProvider: TimelineProvider {
    /// App Group identifier for shared data.
    private let appGroupId = "group.com.turnlab.app"

    func placeholder(in context: Context) -> FocusSkillEntry {
        FocusSkillEntry.placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (FocusSkillEntry) -> Void) {
        if context.isPreview {
            completion(FocusSkillEntry.snapshot)
        } else {
            let entry = loadCurrentFocusSkill()
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FocusSkillEntry>) -> Void) {
        let entry = loadCurrentFocusSkill()

        // Refresh every hour
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))

        completion(timeline)
    }

    // MARK: - Data Loading

    private func loadCurrentFocusSkill() -> FocusSkillEntry {
        guard let userDefaults = UserDefaults(suiteName: appGroupId),
              let focusSkillData = userDefaults.data(forKey: "focusSkill"),
              let focusSkill = try? JSONDecoder().decode(WidgetFocusSkill.self, from: focusSkillData) else {
            return FocusSkillEntry.empty
        }

        return FocusSkillEntry(
            date: Date(),
            skillId: focusSkill.id,
            skillName: focusSkill.name,
            skillLevel: focusSkill.level,
            levelColor: focusSkill.levelColor,
            progress: focusSkill.progress,
            nextMilestone: focusSkill.nextMilestone,
            domain: focusSkill.domain,
            domainIcon: focusSkill.domainIcon
        )
    }
}

/// Codable struct for widget data transfer via App Groups.
struct WidgetFocusSkill: Codable {
    let id: String
    let name: String
    let level: String
    let levelColor: String
    let progress: Double
    let nextMilestone: String?
    let domain: String
    let domainIcon: String
}
