import SwiftUI

/// Card displaying the current focus skill.
struct FocusSkillCard: View {
    let skill: Skill
    let rating: Rating
    var onTap: (() -> Void)?
    var onClear: (() -> Void)?

    var body: some View {
        ContentCard(title: "Current Focus", subtitle: "Tap to view", icon: "target") {
            Button(action: { onTap?() }) {
                HStack(spacing: TurnLabSpacing.md) {
                    // Progress indicator
                    SkillProgressIndicator(rating: rating, size: 56)

                    // Skill info
                    VStack(alignment: .leading, spacing: TurnLabSpacing.xxs) {
                        Text(skill.name)
                            .font(TurnLabTypography.headline)
                            .foregroundStyle(TurnLabColors.textPrimary)

                        HStack(spacing: TurnLabSpacing.xs) {
                            LevelBadge(level: skill.level, size: .small)
                            ForEach(skill.domains.prefix(2)) { domain in
                                DomainTag(domain: domain, showIcon: false, style: .outlined)
                            }
                        }

                        Text(rating.displayName)
                            .font(TurnLabTypography.caption)
                            .foregroundStyle(rating.color)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundStyle(TurnLabColors.textTertiary)
                }
            }
            .buttonStyle(.plain)

            // Quick tips preview
            if let quickTip = skill.content.tips.first(where: { $0.isQuickReference }) {
                Divider()

                HStack(alignment: .top, spacing: TurnLabSpacing.xs) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(.yellow)
                        .font(.caption)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Quick Tip")
                            .font(.caption2)
                            .foregroundStyle(TurnLabColors.textTertiary)
                        Text(quickTip.content)
                            .font(TurnLabTypography.caption)
                            .foregroundStyle(TurnLabColors.textSecondary)
                            .lineLimit(2)
                    }
                }
            }

            // Clear button
            if onClear != nil {
                Button(action: { onClear?() }) {
                    HStack {
                        Image(systemName: "xmark.circle")
                        Text("Clear Focus")
                    }
                    .font(TurnLabTypography.caption)
                    .foregroundStyle(TurnLabColors.textTertiary)
                }
                .padding(.top, TurnLabSpacing.xs)
            }
        }
    }
}

#Preview {
    FocusSkillCard(
        skill: Skill(
            id: "test",
            name: "Parallel Turns",
            level: .intermediate,
            domains: [.rotaryMovements, .edgeControl],
            prerequisites: [],
            summary: "Link parallel turns smoothly on varied terrain.",
            outcomeMilestones: Skill.OutcomeMilestones(
                needsWork: "", developing: "", confident: "", mastered: ""
            ),
            assessmentContexts: [.groomedBlue],
            content: SkillContent(
                videos: [],
                tips: [
                    Tip(id: "1", title: "Lazy Susan", content: "Imagine your feet are on a lazy Susan rotating together.", category: .mentalCue, isQuickReference: true)
                ],
                drills: [],
                checklists: [],
                warnings: []
            )
        ),
        rating: .developing,
        onTap: {},
        onClear: {}
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
