import SwiftUI

/// Section showing suggested skills to work on.
struct SuggestedContentSection: View {
    let skills: [Skill]
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
                    ForEach(skills) { skill in
                        SuggestedSkillCard(
                            skill: skill,
                            onTap: { onSelectSkill(skill) },
                            onSetFocus: { onSetFocus(skill) }
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
    let onTap: () -> Void
    let onSetFocus: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: TurnLabSpacing.xs) {
            // Skill name and level
            HStack {
                LevelBadge(level: skill.level, size: .small)
                Spacer()
            }

            Text(skill.name)
                .font(TurnLabTypography.headline)
                .foregroundStyle(TurnLabColors.textPrimary)
                .lineLimit(2)

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
        .frame(width: 180, height: 160)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: TurnLabSpacing.cornerRadiusMedium))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }
}

#Preview {
    SuggestedContentSection(
        skills: [
            Skill(
                id: "1",
                name: "Parallel Turns",
                level: .intermediate,
                domains: [.rotaryMovements],
                prerequisites: [],
                summary: "Link parallel turns smoothly.",
                outcomeMilestones: Skill.OutcomeMilestones(needsWork: "", developing: "", confident: "", mastered: ""),
                assessmentContexts: [],
                content: SkillContent(videos: [], tips: [], drills: [], checklists: [], warnings: [])
            ),
            Skill(
                id: "2",
                name: "Hockey Stop",
                level: .intermediate,
                domains: [.edgeControl],
                prerequisites: [],
                summary: "Stop quickly and decisively.",
                outcomeMilestones: Skill.OutcomeMilestones(needsWork: "", developing: "", confident: "", mastered: ""),
                assessmentContexts: [],
                content: SkillContent(videos: [], tips: [], drills: [], checklists: [], warnings: [])
            )
        ],
        onSelectSkill: { _ in },
        onSetFocus: { _ in }
    )
    .padding(.vertical)
    .background(Color(.systemGroupedBackground))
}
