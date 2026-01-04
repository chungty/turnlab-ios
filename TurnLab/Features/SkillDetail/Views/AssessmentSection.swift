import SwiftUI

/// Assessment section showing current ratings and assess button.
struct AssessmentSection: View {
    let skill: Skill
    let contextRatings: [TerrainContext: Rating]
    let overallRating: Rating
    let onAssess: () -> Void

    var body: some View {
        ContentCard(title: "Your Assessment", icon: "checkmark.circle") {
            VStack(spacing: TurnLabSpacing.md) {
                // Overall rating
                HStack {
                    VStack(alignment: .leading, spacing: TurnLabSpacing.xxs) {
                        Text("Overall")
                            .font(TurnLabTypography.caption)
                            .foregroundStyle(TurnLabColors.textSecondary)

                        HStack(spacing: TurnLabSpacing.xs) {
                            Image(systemName: overallRating.iconName)
                                .foregroundStyle(overallRating.color)
                            Text(overallRating.displayName)
                                .font(TurnLabTypography.headline)
                                .foregroundStyle(overallRating.color)
                        }
                    }

                    Spacer()

                    PrimaryButton(title: "Assess", icon: "pencil") {
                        onAssess()
                    }
                    .frame(width: 120)
                }

                Divider()

                // Context-specific ratings
                if !skill.assessmentContexts.isEmpty {
                    VStack(alignment: .leading, spacing: TurnLabSpacing.xs) {
                        Text("By Terrain")
                            .font(TurnLabTypography.caption)
                            .foregroundStyle(TurnLabColors.textSecondary)

                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: TurnLabSpacing.xs) {
                            ForEach(skill.assessmentContexts) { context in
                                ContextRatingBadge(
                                    context: context,
                                    rating: contextRatings[context] ?? .notAssessed
                                )
                            }
                        }
                    }
                }

                // Milestone description
                Text(skill.outcomeMilestones.description(for: overallRating))
                    .font(TurnLabTypography.caption)
                    .foregroundStyle(TurnLabColors.textSecondary)
                    .italic()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

struct ContextRatingBadge: View {
    let context: TerrainContext
    let rating: Rating

    var body: some View {
        HStack(spacing: TurnLabSpacing.xxs) {
            Image(systemName: context.iconName)
                .font(.caption)
                .foregroundStyle(TurnLabColors.textSecondary)

            Text(context.shortName)
                .font(.caption)
                .foregroundStyle(TurnLabColors.textPrimary)

            Spacer()

            Circle()
                .fill(rating.color)
                .frame(width: 8, height: 8)
        }
        .padding(.horizontal, TurnLabSpacing.xs)
        .padding(.vertical, TurnLabSpacing.xxs)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

#Preview {
    AssessmentSection(
        skill: Skill(
            id: "test",
            name: "Parallel Turns",
            level: .intermediate,
            domains: [.rotaryMovements],
            prerequisites: [],
            summary: "Link parallel turns smoothly.",
            outcomeMilestones: Skill.OutcomeMilestones(
                needsWork: "Skis frequently cross or wedge",
                developing: "Can make turns on easy terrain",
                confident: "Links turns naturally on blues",
                mastered: "Controls turn shape on any groomed"
            ),
            assessmentContexts: [.groomedBlue, .groomedBlack, .crud],
            content: SkillContent(videos: [], tips: [], drills: [], checklists: [], warnings: [])
        ),
        contextRatings: [.groomedBlue: .confident, .groomedBlack: .developing],
        overallRating: .confident,
        onAssess: {}
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
