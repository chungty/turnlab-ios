import SwiftUI

/// Row view for skill in browser list.
struct SkillRowView: View {
    let skill: Skill
    let rating: Rating
    let isLocked: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: TurnLabSpacing.sm) {
                // Rating indicator
                SkillProgressIndicator(rating: rating, size: 44)

                // Content
                VStack(alignment: .leading, spacing: TurnLabSpacing.xxs) {
                    HStack {
                        Text(skill.name)
                            .font(TurnLabTypography.headline)
                            .foregroundStyle(TurnLabColors.textPrimary)

                        if skill.level.requiresPremium {
                            Image(systemName: "crown.fill")
                                .font(.caption2)
                                .foregroundStyle(.yellow)
                        }
                    }

                    Text(skill.summary)
                        .font(TurnLabTypography.caption)
                        .foregroundStyle(TurnLabColors.textSecondary)
                        .lineLimit(2)
                        .lineSpacing(2)

                    // Domain tags
                    HStack(spacing: 4) {
                        ForEach(skill.domains.prefix(3)) { domain in
                            Image(systemName: domain.iconName)
                                .font(.caption2)
                                .foregroundStyle(domain.color)
                        }
                    }
                }

                Spacer()

                // Lock or chevron
                if isLocked {
                    VStack {
                        Image(systemName: "lock.fill")
                            .foregroundStyle(TurnLabColors.textTertiary)
                        Text("Premium")
                            .font(.caption2)
                            .foregroundStyle(TurnLabColors.textTertiary)
                    }
                    .accessibilityHidden(true) // Covered by button accessibility
                } else {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(TurnLabColors.textTertiary)
                        .accessibilityHidden(true)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: TurnLabSpacing.cornerRadiusMedium))
        }
        .buttonStyle(.plain)
        .opacity(isLocked ? 0.7 : 1)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint)
    }

    // MARK: - Accessibility

    private var accessibilityLabel: String {
        let lockStatus = isLocked ? "Locked premium skill" : "Skill"
        let ratingStatus = rating == .notAssessed ? "not assessed" : rating.displayName
        return "\(lockStatus): \(skill.name), \(skill.level.displayName) level, \(ratingStatus)"
    }

    private var accessibilityHint: String {
        if isLocked {
            return "Double tap to view unlock options"
        } else {
            return "Double tap to view skill details"
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        SkillRowView(
            skill: Skill(
                id: "1",
                name: "Parallel Turns",
                level: .intermediate,
                domains: [.rotaryMovements, .edgeControl],
                prerequisites: [],
                summary: "Link parallel turns smoothly on varied terrain with control.",
                outcomeMilestones: Skill.OutcomeMilestones(needsWork: "", developing: "", confident: "", mastered: ""),
                assessmentContexts: [],
                content: SkillContent(videos: [], tips: [], drills: [], checklists: [], warnings: [])
            ),
            rating: .confident,
            isLocked: false,
            onTap: {}
        )

        SkillRowView(
            skill: Skill(
                id: "2",
                name: "Mogul Skiing",
                level: .expert,
                domains: [.terrainAdaptation, .pressureManagement],
                prerequisites: [],
                summary: "Navigate mogul fields with rhythm and control.",
                outcomeMilestones: Skill.OutcomeMilestones(needsWork: "", developing: "", confident: "", mastered: ""),
                assessmentContexts: [],
                content: SkillContent(videos: [], tips: [], drills: [], checklists: [], warnings: [])
            ),
            rating: .notAssessed,
            isLocked: true,
            onTap: {}
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
