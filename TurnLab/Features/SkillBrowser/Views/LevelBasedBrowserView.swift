import SwiftUI

/// Skills organized by level.
struct LevelBasedBrowserView: View {
    let skillsByLevel: [SkillLevel: [Skill]]
    let rating: (Skill) -> Rating
    let isLocked: (Skill) -> Bool
    let onSelectSkill: (Skill) -> Void

    var body: some View {
        LazyVStack(spacing: TurnLabSpacing.lg, pinnedViews: [.sectionHeaders]) {
            ForEach(SkillLevel.allCases, id: \.self) { level in
                if let skills = skillsByLevel[level], !skills.isEmpty {
                    Section {
                        ForEach(skills) { skill in
                            SkillRowView(
                                skill: skill,
                                rating: rating(skill),
                                isLocked: isLocked(skill),
                                onTap: { onSelectSkill(skill) }
                            )
                        }
                    } header: {
                        LevelSectionHeader(level: level, skillCount: skills.count)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

struct LevelSectionHeader: View {
    let level: SkillLevel
    let skillCount: Int

    var body: some View {
        HStack(spacing: TurnLabSpacing.sm) {
            // Level icon with gradient background
            ZStack {
                Circle()
                    .fill(TurnLabColors.levelGradient(level))
                    .frame(width: 32, height: 32)

                Image(systemName: levelIcon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 0) {
                Text(level.displayName)
                    .font(TurnLabTypography.headline)
                    .foregroundStyle(TurnLabColors.textPrimary)

                Text(level.description)
                    .font(.caption2)
                    .foregroundStyle(TurnLabColors.textSecondary)
            }

            Spacer()

            Text("\(skillCount)")
                .font(TurnLabTypography.title3)
                .fontWeight(.bold)
                .foregroundStyle(TurnLabColors.levelColor(level))
            + Text(" skills")
                .font(TurnLabTypography.caption)
                .foregroundStyle(TurnLabColors.textTertiary)
        }
        .padding(.vertical, TurnLabSpacing.sm)
        .padding(.horizontal, TurnLabSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: TurnLabSpacing.cornerRadiusSmall)
                .fill(Color(.systemBackground))
                .shadow(color: TurnLabColors.levelColor(level).opacity(0.1), radius: 4, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: TurnLabSpacing.cornerRadiusSmall)
                .stroke(TurnLabColors.levelColor(level).opacity(0.2), lineWidth: 1)
        )
    }

    private var levelIcon: String {
        switch level {
        case .beginner: return "figure.stand"
        case .novice: return "figure.skiing.downhill"
        case .intermediate: return "mountain.2"
        case .expert: return "snowflake"
        }
    }
}

#Preview {
    let skills: [SkillLevel: [Skill]] = [
        .beginner: [
            Skill(
                id: "1",
                name: "Basic Stance",
                level: .beginner,
                domains: [.balance],
                prerequisites: [],
                summary: "Learn the fundamental athletic stance.",
                outcomeMilestones: Skill.OutcomeMilestones(needsWork: "", developing: "", confident: "", mastered: ""),
                assessmentContexts: [],
                content: SkillContent(videos: [], tips: [], drills: [], checklists: [], warnings: [])
            )
        ],
        .intermediate: [
            Skill(
                id: "2",
                name: "Parallel Turns",
                level: .intermediate,
                domains: [.rotaryMovements],
                prerequisites: [],
                summary: "Link parallel turns smoothly.",
                outcomeMilestones: Skill.OutcomeMilestones(needsWork: "", developing: "", confident: "", mastered: ""),
                assessmentContexts: [],
                content: SkillContent(videos: [], tips: [], drills: [], checklists: [], warnings: [])
            )
        ]
    ]

    ScrollView {
        LevelBasedBrowserView(
            skillsByLevel: skills,
            rating: { _ in .developing },
            isLocked: { $0.level != .beginner },
            onSelectSkill: { _ in }
        )
    }
}
