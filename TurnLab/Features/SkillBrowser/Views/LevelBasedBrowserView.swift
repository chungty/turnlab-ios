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
        HStack {
            LevelBadge(level: level, size: .medium)

            Text(level.description)
                .font(TurnLabTypography.caption)
                .foregroundStyle(TurnLabColors.textSecondary)

            Spacer()

            Text("\(skillCount) skills")
                .font(TurnLabTypography.caption)
                .foregroundStyle(TurnLabColors.textTertiary)
        }
        .padding(.vertical, TurnLabSpacing.xs)
        .padding(.horizontal, TurnLabSpacing.sm)
        .background(Color(.systemGroupedBackground))
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
