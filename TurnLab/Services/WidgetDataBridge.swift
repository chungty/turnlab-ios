import Foundation
import WidgetKit

/// Bridge for sharing data between the main app and widget extension.
/// Uses App Group UserDefaults for cross-process communication.
final class WidgetDataBridge {
    // MARK: - Singleton
    static let shared = WidgetDataBridge()

    // MARK: - Constants
    private let appGroupId = "group.com.turnlab.app"
    private let focusSkillKey = "focusSkill"

    // MARK: - UserDefaults
    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupId)
    }

    private init() {}

    // MARK: - Public API

    /// Updates the widget with the current focus skill.
    /// - Parameters:
    ///   - skill: The skill to display in the widget
    ///   - progress: Current progress (0.0 - 1.0)
    ///   - nextMilestone: Optional text for the next goal
    func updateFocusSkill(_ skill: Skill, progress: Double, nextMilestone: String?) {
        let widgetData = WidgetFocusSkillData(
            id: skill.id,
            name: skill.name,
            level: skill.level.displayName,
            levelColor: levelColorString(for: skill.level),
            progress: progress,
            nextMilestone: nextMilestone,
            domain: skill.domains.first?.displayName ?? "Skiing",
            domainIcon: skill.domains.first?.iconName ?? "figure.skiing.downhill"
        )

        saveToSharedDefaults(widgetData)
        reloadWidgets()
    }

    /// Clears the focus skill from the widget.
    func clearFocusSkill() {
        sharedDefaults?.removeObject(forKey: focusSkillKey)
        reloadWidgets()
    }

    // MARK: - Private Helpers

    private func saveToSharedDefaults(_ data: WidgetFocusSkillData) {
        guard let encoded = try? JSONEncoder().encode(data) else {
            print("[WidgetDataBridge] Failed to encode widget data")
            return
        }
        sharedDefaults?.set(encoded, forKey: focusSkillKey)
    }

    private func reloadWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func levelColorString(for level: SkillLevel) -> String {
        switch level {
        case .beginner: return "green"
        case .novice: return "blue"
        case .intermediate: return "orange"
        case .expert: return "red"
        }
    }
}

// MARK: - Widget Data Model (mirrors WidgetFocusSkill in widget target)

/// Codable struct for widget data transfer.
/// Must match the WidgetFocusSkill struct in TurnLabWidget.
private struct WidgetFocusSkillData: Codable {
    let id: String
    let name: String
    let level: String
    let levelColor: String
    let progress: Double
    let nextMilestone: String?
    let domain: String
    let domainIcon: String
}
