import SwiftUI

/// Typography system with Dynamic Type support.
/// Optimized for readability in varying conditions.
enum TurnLabTypography {
    // MARK: - Display Styles (Large Headers)
    static let largeTitle = Font.largeTitle.weight(.bold)
    static let title1 = Font.title.weight(.bold)
    static let title2 = Font.title2.weight(.semibold)
    static let title3 = Font.title3.weight(.semibold)

    // MARK: - Body Styles
    static let headline = Font.headline
    static let body = Font.body
    static let callout = Font.callout
    static let subheadline = Font.subheadline
    static let footnote = Font.footnote
    static let caption = Font.caption
    static let caption2 = Font.caption2

    // MARK: - Custom Styles
    static let skillName = Font.system(.title2, design: .rounded, weight: .bold)
    static let levelBadge = Font.system(.caption, design: .rounded, weight: .semibold)
    static let statValue = Font.system(.title, design: .rounded, weight: .bold)
    static let statLabel = Font.system(.caption, design: .rounded, weight: .medium)
    static let quickTip = Font.system(.callout, design: .default, weight: .medium)

    // MARK: - Monospaced (for timers, counts)
    static let mono = Font.system(.body, design: .monospaced)
    static let monoLarge = Font.system(.title2, design: .monospaced, weight: .bold)
}

// MARK: - Text Style Modifiers
struct SkillNameStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(TurnLabTypography.skillName)
            .foregroundStyle(TurnLabColors.textPrimary)
    }
}

struct QuickReferenceStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(TurnLabTypography.quickTip)
            .foregroundStyle(TurnLabColors.textPrimary)
            .lineSpacing(4)
    }
}

struct StatValueStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(TurnLabTypography.statValue)
            .foregroundStyle(TurnLabColors.textPrimary)
    }
}

extension View {
    func skillNameStyle() -> some View {
        modifier(SkillNameStyle())
    }

    func quickReferenceStyle() -> some View {
        modifier(QuickReferenceStyle())
    }

    func statValueStyle() -> some View {
        modifier(StatValueStyle())
    }
}
