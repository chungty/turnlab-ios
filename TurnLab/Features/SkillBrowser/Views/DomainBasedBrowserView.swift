import SwiftUI

/// Skills organized by domain.
struct DomainBasedBrowserView: View {
    let skillsByDomain: [SkillDomain: [Skill]]
    let rating: (Skill) -> Rating
    let isLocked: (Skill) -> Bool
    let onSelectSkill: (Skill) -> Void

    var body: some View {
        LazyVStack(spacing: TurnLabSpacing.lg, pinnedViews: [.sectionHeaders]) {
            ForEach(SkillDomain.allCases) { domain in
                if let skills = skillsByDomain[domain], !skills.isEmpty {
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
                        DomainSectionHeader(domain: domain, skillCount: skills.count)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

struct DomainSectionHeader: View {
    let domain: SkillDomain
    let skillCount: Int

    var body: some View {
        HStack {
            Image(systemName: domain.iconName)
                .foregroundStyle(domain.color)

            Text(domain.displayName)
                .font(TurnLabTypography.headline)
                .foregroundStyle(TurnLabColors.textPrimary)

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
    let skills: [SkillDomain: [Skill]] = [
        .balance: [
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
        .edgeControl: [
            Skill(
                id: "2",
                name: "Edge Awareness",
                level: .novice,
                domains: [.edgeControl],
                prerequisites: [],
                summary: "Understand how edges grip the snow.",
                outcomeMilestones: Skill.OutcomeMilestones(needsWork: "", developing: "", confident: "", mastered: ""),
                assessmentContexts: [],
                content: SkillContent(videos: [], tips: [], drills: [], checklists: [], warnings: [])
            )
        ]
    ]

    ScrollView {
        DomainBasedBrowserView(
            skillsByDomain: skills,
            rating: { _ in .confident },
            isLocked: { _ in false },
            onSelectSkill: { _ in }
        )
    }
}
