import SwiftUI

/// Section showing suggested skills to work on with explanations for why they're recommended.
struct SuggestedContentSection: View {
    let suggestions: [SuggestedSkillWithReason]
    let onSelectSkill: (Skill) -> Void
    let onSetFocus: (Skill) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: TurnLabSpacing.sm) {
            // Header
            HStack {
                Image(systemName: "sparkles")
                    .foregroundStyle(Color.accentColor)
                Text("Suggested for You")
                    .font(TurnLabTypography.headline)
                    .foregroundStyle(TurnLabColors.textPrimary)
            }
            .padding(.horizontal, TurnLabSpacing.cardPadding)

            // Horizontal scroll of skill cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: TurnLabSpacing.sm) {
                    ForEach(suggestions) { suggestion in
                        SuggestedSkillCard(
                            skill: suggestion.skill,
                            reason: suggestion.reason,
                            onTap: { onSelectSkill(suggestion.skill) },
                            onSetFocus: { onSetFocus(suggestion.skill) }
                        )
                    }
                }
                .padding(.horizontal, TurnLabSpacing.cardPadding)
            }
        }
    }
}

struct SuggestedSkillCard: View {
    let skill: Skill
    let reason: RecommendationReason
    let onTap: () -> Void
    let onSetFocus: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: TurnLabSpacing.xs) {
            // Reason badge - explains WHY this skill is suggested
            HStack(spacing: 4) {
                Image(systemName: reason.icon)
                    .font(.system(size: 10))
                Text(reason.displayText)
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundStyle(reasonColor)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(reasonColor.opacity(0.1))
            .clipShape(Capsule())

            // Skill name and level
            HStack {
                Text(skill.name)
                    .font(TurnLabTypography.headline)
                    .foregroundStyle(TurnLabColors.textPrimary)
                    .lineLimit(2)

                Spacer()

                LevelBadge(level: skill.level, size: .small)
            }

            Text(skill.summary)
                .font(TurnLabTypography.caption)
                .foregroundStyle(TurnLabColors.textSecondary)
                .lineLimit(2)

            Spacer()

            // Actions
            HStack(spacing: TurnLabSpacing.xs) {
                Button(action: onTap) {
                    HStack(spacing: 4) {
                        Image(systemName: "eye")
                        Text("View")
                    }
                    .font(.caption)
                    .foregroundStyle(Color.accentColor)
                }

                Spacer()

                Button(action: onSetFocus) {
                    HStack(spacing: 4) {
                        Image(systemName: "target")
                        Text("Focus")
                    }
                    .font(.caption)
                    .foregroundStyle(TurnLabColors.textSecondary)
                }
            }
        }
        .padding()
        .frame(width: 180, height: 170)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: TurnLabSpacing.cornerRadiusMedium))
        .overlay(
            RoundedRectangle(cornerRadius: TurnLabSpacing.cornerRadiusMedium)
                .stroke(TurnLabColors.levelColor(skill.level).opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    private var reasonColor: Color {
        switch reason {
        case .buildingFoundation:
            return .green
        case .notYetAssessed:
            return .blue
        case .needsMorePractice:
            return .orange
        case .nextInProgression:
            return .purple
        case .domainBalance:
            return .cyan
        }
    }
}

#Preview {
    SuggestedContentSection(
        suggestions: [
            SuggestedSkillWithReason(
                skill: Skill(
                    id: "1",
                    name: "Basic Stance",
                    level: .beginner,
                    domains: [.balance],
                    prerequisites: [],
                    summary: "Learn the fundamental athletic stance.",
                    outcomeMilestones: Skill.OutcomeMilestones(needsWork: "", developing: "", confident: "", mastered: ""),
                    assessmentContexts: [],
                    content: SkillContent(videos: [], tips: [], drills: [], checklists: [], warnings: [])
                ),
                reason: .buildingFoundation
            ),
            SuggestedSkillWithReason(
                skill: Skill(
                    id: "2",
                    name: "Wedge Turns",
                    level: .beginner,
                    domains: [.rotaryMovements],
                    prerequisites: [],
                    summary: "Control your speed and direction.",
                    outcomeMilestones: Skill.OutcomeMilestones(needsWork: "", developing: "", confident: "", mastered: ""),
                    assessmentContexts: [],
                    content: SkillContent(videos: [], tips: [], drills: [], checklists: [], warnings: [])
                ),
                reason: .notYetAssessed
            ),
            SuggestedSkillWithReason(
                skill: Skill(
                    id: "3",
                    name: "Hockey Stop",
                    level: .intermediate,
                    domains: [.edgeControl],
                    prerequisites: [],
                    summary: "Stop quickly and decisively.",
                    outcomeMilestones: Skill.OutcomeMilestones(needsWork: "", developing: "", confident: "", mastered: ""),
                    assessmentContexts: [],
                    content: SkillContent(videos: [], tips: [], drills: [], checklists: [], warnings: [])
                ),
                reason: .needsMorePractice
            )
        ],
        onSelectSkill: { _ in },
        onSetFocus: { _ in }
    )
    .padding(.vertical)
    .background(Color(.systemGroupedBackground))
}
