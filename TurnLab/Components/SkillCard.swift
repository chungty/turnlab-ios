import SwiftUI

/// Card displaying skill summary with rating indicator.
struct SkillCard: View {
    let skill: Skill
    let rating: Rating
    var isLocked: Bool = false
    var onTap: (() -> Void)?

    var body: some View {
        Button(action: { onTap?() }) {
            HStack(spacing: TurnLabSpacing.sm) {
                // Rating indicator
                SkillProgressIndicator(rating: rating)

                // Content
                VStack(alignment: .leading, spacing: TurnLabSpacing.xxs) {
                    Text(skill.name)
                        .font(TurnLabTypography.headline)
                        .foregroundStyle(TurnLabColors.textPrimary)
                        .lineLimit(1)

                    Text(skill.summary)
                        .font(TurnLabTypography.caption)
                        .foregroundStyle(TurnLabColors.textSecondary)
                        .lineLimit(2)

                    // Domain tags
                    HStack(spacing: 4) {
                        ForEach(skill.domains.prefix(2)) { domain in
                            DomainTag(domain: domain, showIcon: false, style: .outlined)
                        }
                    }
                }

                Spacer()

                // Lock or chevron
                if isLocked {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(TurnLabColors.textTertiary)
                } else {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(TurnLabColors.textTertiary)
                }
            }
            .cardPadding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: TurnLabSpacing.cornerRadiusMedium))
            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
        .opacity(isLocked ? 0.6 : 1)
    }
}

#Preview {
    VStack(spacing: 12) {
        SkillCard(
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
                content: SkillContent(videos: [], tips: [], drills: [], checklists: [], warnings: [])
            ),
            rating: .confident
        )

        SkillCard(
            skill: Skill(
                id: "test2",
                name: "Mogul Skiing",
                level: .expert,
                domains: [.terrainAdaptation],
                prerequisites: [],
                summary: "Navigate mogul fields with confidence.",
                outcomeMilestones: Skill.OutcomeMilestones(
                    needsWork: "", developing: "", confident: "", mastered: ""
                ),
                assessmentContexts: [.bumps],
                content: SkillContent(videos: [], tips: [], drills: [], checklists: [], warnings: [])
            ),
            rating: .notAssessed,
            isLocked: true
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
