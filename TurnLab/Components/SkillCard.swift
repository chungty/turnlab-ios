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
                // Rating indicator with level color accent
                ZStack {
                    Circle()
                        .fill(TurnLabColors.levelColor(skill.level).opacity(0.1))
                        .frame(width: 52, height: 52)

                    SkillProgressIndicator(rating: rating)
                }

                // Content
                VStack(alignment: .leading, spacing: TurnLabSpacing.xxs) {
                    HStack(alignment: .top, spacing: TurnLabSpacing.xs) {
                        Text(skill.name)
                            .font(TurnLabTypography.headline)
                            .foregroundStyle(TurnLabColors.textPrimary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)

                        Spacer()

                        // Level indicator
                        Text(skill.level.displayName)
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundStyle(TurnLabColors.levelColor(skill.level))
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(TurnLabColors.levelColor(skill.level).opacity(0.15))
                            )
                    }

                    Text(skill.summary)
                        .font(TurnLabTypography.caption)
                        .foregroundStyle(TurnLabColors.textSecondary)
                        .lineLimit(3)
                        .lineSpacing(2)

                    // Domain tags
                    HStack(spacing: 4) {
                        ForEach(skill.domains.prefix(2)) { domain in
                            DomainTag(domain: domain, showIcon: false, style: .outlined)
                        }
                    }
                }

                // Lock or chevron
                if isLocked {
                    VStack {
                        Image(systemName: "lock.fill")
                            .foregroundStyle(TurnLabColors.textTertiary)
                        Text("Premium")
                            .font(.caption2)
                            .foregroundStyle(TurnLabColors.textTertiary)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Locked")
                    .accessibilityHidden(true) // Covered by button accessibility
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(TurnLabColors.levelColor(skill.level))
                        .accessibilityHidden(true)
                }
            }
            .cardPadding()
            .background(
                RoundedRectangle(cornerRadius: TurnLabSpacing.cornerRadiusMedium)
                    .fill(Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: TurnLabSpacing.cornerRadiusMedium)
                    .stroke(
                        isLocked ? Color.gray.opacity(0.2) : TurnLabColors.levelColor(skill.level).opacity(0.15),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: isLocked ? .clear : TurnLabColors.levelColor(skill.level).opacity(0.08),
                radius: 6,
                y: 3
            )
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
