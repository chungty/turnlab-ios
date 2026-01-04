import SwiftUI

/// Hero section at top of skill detail.
struct SkillHeroSection: View {
    let skill: Skill
    let rating: Rating
    let isFocusSkill: Bool
    let onSetFocus: () -> Void
    let onRemoveFocus: () -> Void

    var body: some View {
        VStack(spacing: TurnLabSpacing.md) {
            // Background with level color
            ZStack {
                TurnLabColors.levelColor(skill.level)
                    .opacity(0.15)

                VStack(spacing: TurnLabSpacing.md) {
                    // Rating and level
                    HStack {
                        SkillProgressIndicator(rating: rating, size: 64)

                        VStack(alignment: .leading, spacing: TurnLabSpacing.xxs) {
                            Text(skill.name)
                                .font(TurnLabTypography.title2)
                                .foregroundStyle(TurnLabColors.textPrimary)

                            HStack(spacing: TurnLabSpacing.xs) {
                                LevelBadge(level: skill.level)
                                Text(rating.displayName)
                                    .font(TurnLabTypography.caption)
                                    .foregroundStyle(rating.color)
                            }
                        }

                        Spacer()

                        // Focus button
                        Button(action: isFocusSkill ? onRemoveFocus : onSetFocus) {
                            VStack(spacing: 2) {
                                Image(systemName: isFocusSkill ? "target" : "plus.circle")
                                    .font(.title2)
                                Text(isFocusSkill ? "Focused" : "Set Focus")
                                    .font(.caption2)
                            }
                            .foregroundStyle(isFocusSkill ? Color.accentColor : TurnLabColors.textSecondary)
                        }
                    }

                    // Summary
                    Text(skill.summary)
                        .font(TurnLabTypography.body)
                        .foregroundStyle(TurnLabColors.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // Domain tags
                    HStack(spacing: TurnLabSpacing.xs) {
                        ForEach(skill.domains) { domain in
                            DomainTag(domain: domain, style: .filled)
                        }
                        Spacer()
                    }
                }
                .padding()
            }
        }
    }
}

#Preview {
    SkillHeroSection(
        skill: Skill(
            id: "test",
            name: "Parallel Turns",
            level: .intermediate,
            domains: [.rotaryMovements, .edgeControl, .balance],
            prerequisites: [],
            summary: "Link parallel turns smoothly on varied terrain while maintaining control and rhythm.",
            outcomeMilestones: Skill.OutcomeMilestones(needsWork: "", developing: "", confident: "", mastered: ""),
            assessmentContexts: [],
            content: SkillContent(videos: [], tips: [], drills: [], checklists: [], warnings: [])
        ),
        rating: .developing,
        isFocusSkill: false,
        onSetFocus: {},
        onRemoveFocus: {}
    )
}
