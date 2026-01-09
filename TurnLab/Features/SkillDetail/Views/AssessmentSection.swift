import SwiftUI

/// Assessment section with inline rating picker for direct, frictionless assessment.
/// Replaces the previous modal-based flow with 1-tap assessment that auto-saves.
struct AssessmentSection: View {
    let skill: Skill
    let contextRatings: [TerrainContext: Rating]
    let overallRating: Rating
    let onRatingSelected: (Rating) -> Void
    var isSaving: Bool = false
    var showSaveSuccess: Bool = false

    @State private var selectedRating: Rating = .notAssessed

    var body: some View {
        ContentCard(title: "Your Assessment", icon: "checkmark.circle") {
            VStack(spacing: TurnLabSpacing.md) {
                // Terrain context label (shows WHERE this assessment applies)
                if let primaryContext = skill.assessmentContexts.first {
                    HStack(spacing: TurnLabSpacing.xs) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundStyle(TurnLabColors.textSecondary)
                        Text("Assessed on: \(primaryContext.displayName)")
                            .font(TurnLabTypography.caption)
                            .foregroundStyle(TurnLabColors.textSecondary)
                        Spacer()
                    }
                }

                // Inline assessment picker
                AssessmentPicker(
                    selectedRating: $selectedRating,
                    milestones: skill.outcomeMilestones,
                    currentRating: overallRating,
                    onRatingSelected: onRatingSelected,
                    isSaving: isSaving,
                    showSaveSuccess: showSaveSuccess
                )

                // Context-specific ratings (collapsed view)
                if skill.assessmentContexts.count > 1 {
                    Divider()

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
            }
        }
        .onAppear {
            // Initialize selected rating to current overall rating
            selectedRating = overallRating
        }
        .onChange(of: overallRating) { _, newValue in
            // Sync selected rating when overall rating changes (e.g., after save)
            selectedRating = newValue
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

#Preview("Interactive") {
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
        onRatingSelected: { rating in
            print("Selected: \(rating)")
        }
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Saving State") {
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
            assessmentContexts: [.groomedBlue],
            content: SkillContent(videos: [], tips: [], drills: [], checklists: [], warnings: [])
        ),
        contextRatings: [:],
        overallRating: .developing,
        onRatingSelected: { _ in },
        isSaving: true
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Success State") {
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
            assessmentContexts: [.groomedBlue],
            content: SkillContent(videos: [], tips: [], drills: [], checklists: [], warnings: [])
        ),
        contextRatings: [:],
        overallRating: .confident,
        onRatingSelected: { _ in },
        showSaveSuccess: true
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
