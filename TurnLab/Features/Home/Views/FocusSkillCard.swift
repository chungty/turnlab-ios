import SwiftUI

/// Card displaying the current focus skill with actionable guidance.
/// Shows WHERE to practice, WHAT success looks like, and a MENTAL CUE for the lift ride.
struct FocusSkillCard: View {
    let skill: Skill
    let rating: Rating
    var onTap: (() -> Void)?
    var onClear: (() -> Void)?

    @State private var isExpanded: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header Section
            headerSection

            Divider()
                .padding(.vertical, TurnLabSpacing.sm)

            // Main Content
            VStack(alignment: .leading, spacing: TurnLabSpacing.md) {
                // WHERE TO PRACTICE
                if !skill.assessmentContexts.isEmpty {
                    terrainSection
                }

                // NEXT MILESTONE (What Success Looks Like)
                if let nextMilestone = nextMilestoneText {
                    milestoneSection(nextMilestone)
                }

                // MENTAL CUE
                if let quickTip = mentalCue {
                    mentalCueSection(quickTip)
                }
            }

            Divider()
                .padding(.vertical, TurnLabSpacing.sm)

            // Footer Actions
            footerSection
        }
        .padding(TurnLabSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: TurnLabSpacing.cornerRadiusMedium)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: TurnLabSpacing.cornerRadiusMedium)
                .stroke(Color.accentColor.opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - Header Section

    private var headerSection: some View {
        Button(action: { onTap?() }) {
            HStack(spacing: TurnLabSpacing.md) {
                // Progress indicator
                SkillProgressIndicator(rating: rating, size: 56)

                // Skill info
                VStack(alignment: .leading, spacing: TurnLabSpacing.xxs) {
                    HStack(spacing: TurnLabSpacing.xxs) {
                        Image(systemName: "target")
                            .font(.caption)
                            .foregroundStyle(Color.accentColor)
                        Text("YOUR FOCUS")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.accentColor)
                    }

                    Text(skill.name)
                        .font(TurnLabTypography.headline)
                        .foregroundStyle(TurnLabColors.textPrimary)
                        .multilineTextAlignment(.leading)

                    HStack(spacing: TurnLabSpacing.xs) {
                        LevelBadge(level: skill.level, size: .small)
                        Text("·")
                            .foregroundStyle(TurnLabColors.textTertiary)
                        Text(rating.displayName)
                            .font(TurnLabTypography.caption)
                            .foregroundStyle(rating.color)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(TurnLabColors.textTertiary)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Terrain Section

    private var terrainSection: some View {
        VStack(alignment: .leading, spacing: TurnLabSpacing.xs) {
            Label("WHERE TO PRACTICE", systemImage: "mappin.circle.fill")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(TurnLabColors.textSecondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: TurnLabSpacing.xs) {
                    ForEach(skill.assessmentContexts) { context in
                        TerrainBadge(terrain: context, style: .subtle, size: .medium)
                    }
                }
            }
        }
    }

    // MARK: - Milestone Section

    private func milestoneSection(_ milestone: String) -> some View {
        VStack(alignment: .leading, spacing: TurnLabSpacing.xs) {
            Label("YOUR NEXT MILESTONE", systemImage: "flag.fill")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(TurnLabColors.textSecondary)

            Text(milestone)
                .font(TurnLabTypography.body)
                .foregroundStyle(TurnLabColors.textPrimary)
                .lineSpacing(4)
                .padding(TurnLabSpacing.sm)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: TurnLabSpacing.cornerRadiusSmall)
                        .fill(Color.accentColor.opacity(0.08))
                )
        }
    }

    // MARK: - Mental Cue Section

    private func mentalCueSection(_ tip: Tip) -> some View {
        VStack(alignment: .leading, spacing: TurnLabSpacing.xs) {
            Label("MENTAL CUE", systemImage: "brain.head.profile")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(TurnLabColors.textSecondary)

            HStack(alignment: .top, spacing: TurnLabSpacing.sm) {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(.yellow)
                    .font(.title3)

                VStack(alignment: .leading, spacing: 2) {
                    if !tip.title.isEmpty {
                        Text(tip.title)
                            .font(TurnLabTypography.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(TurnLabColors.textPrimary)
                    }
                    Text(tip.content)
                        .font(TurnLabTypography.body)
                        .foregroundStyle(TurnLabColors.textSecondary)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(TurnLabSpacing.sm)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: TurnLabSpacing.cornerRadiusSmall)
                    .fill(Color.yellow.opacity(0.1))
            )
        }
    }

    // MARK: - Footer Section

    private var footerSection: some View {
        HStack {
            Button(action: { onTap?() }) {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.right.circle")
                    Text("View Full Details")
                }
                .font(TurnLabTypography.caption)
                .fontWeight(.medium)
                .foregroundStyle(Color.accentColor)
            }

            Spacer()

            if onClear != nil {
                Button(action: { onClear?() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "xmark.circle")
                        Text("Clear Focus")
                    }
                    .font(TurnLabTypography.caption)
                    .foregroundStyle(TurnLabColors.textTertiary)
                }
            }
        }
    }

    // MARK: - Computed Properties

    /// Gets the milestone description for the next rating level.
    private var nextMilestoneText: String? {
        let targetRating = rating.nextLevel ?? rating
        let milestone = skill.outcomeMilestones.description(for: targetRating)

        // Don't show if it's empty or the default "Not yet assessed"
        guard !milestone.isEmpty, milestone != "Not yet assessed" else {
            return nil
        }

        return milestone
    }

    /// Gets the first quick reference tip as a mental cue.
    private var mentalCue: Tip? {
        skill.content.tips.first { $0.isQuickReference }
    }
}

#Preview("With Full Content") {
    ScrollView {
        FocusSkillCard(
            skill: Skill(
                id: "test",
                name: "Basic Parallel Turns",
                level: .intermediate,
                domains: [.rotaryMovements, .edgeControl],
                prerequisites: [],
                summary: "Link parallel turns smoothly on varied terrain while maintaining rhythm and control.",
                outcomeMilestones: Skill.OutcomeMilestones(
                    needsWork: "Can attempt parallel turns but reverts to wedge frequently",
                    developing: "Links 3-4 parallel turns with consistent rhythm on groomed terrain",
                    confident: "Maintains parallel stance through varied turn shapes and speeds",
                    mastered: "Parallel turns are automatic with precise edge and pressure control"
                ),
                assessmentContexts: [.groomedBlue, .groomedGreen, .groomedBlack],
                content: SkillContent(
                    videos: [],
                    tips: [
                        Tip(
                            id: "1",
                            title: "Lazy Susan",
                            content: "Imagine your feet are on a lazy Susan - they rotate together as a unit. Shift your weight from the old outside ski to the new outside ski to initiate each turn.",
                            category: .mentalCue,
                            isQuickReference: true
                        )
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
    }
    .background(Color(.systemGroupedBackground))
}

#Preview("Not Assessed") {
    FocusSkillCard(
        skill: Skill(
            id: "test2",
            name: "Pole Plants",
            level: .novice,
            domains: [.rotaryMovements],
            prerequisites: [],
            summary: "Use pole plants to initiate turns with proper timing.",
            outcomeMilestones: Skill.OutcomeMilestones(
                needsWork: "Pole plants are inconsistent or incorrectly timed",
                developing: "Plants pole at turn initiation with reasonable timing",
                confident: "Pole plant timing is consistent and aids turn initiation",
                mastered: "Pole plants are automatic and adapt to terrain variations"
            ),
            assessmentContexts: [.groomedBlue],
            content: SkillContent(
                videos: [],
                tips: [],
                drills: [],
                checklists: [],
                warnings: []
            )
        ),
        rating: .notAssessed,
        onTap: {},
        onClear: {}
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
