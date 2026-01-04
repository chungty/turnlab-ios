import SwiftUI

/// Main dashboard view.
struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @EnvironmentObject private var container: DIContainer

    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: TurnLabSpacing.lg) {
                // Level progress card
                LevelProgressCard(
                    level: viewModel.currentLevel,
                    progress: viewModel.levelProgress,
                    canAdvance: viewModel.canAdvanceLevel,
                    nextLevel: viewModel.nextLevel
                )

                // Focus skill card
                if let focusSkill = viewModel.focusSkill {
                    FocusSkillCard(
                        skill: focusSkill,
                        rating: viewModel.focusSkillRating,
                        onTap: {
                            container.appState.navigateToSkill(focusSkill.id)
                        },
                        onClear: {
                            viewModel.clearFocusSkill()
                        }
                    )
                }

                // Suggested skills section
                if !viewModel.suggestedSkills.isEmpty {
                    SuggestedContentSection(
                        skills: viewModel.suggestedSkills,
                        onSelectSkill: { skill in
                            container.appState.navigateToSkill(skill.id)
                        },
                        onSetFocus: { skill in
                            viewModel.setFocusSkill(skill)
                        }
                    )
                }

                // Quick stats
                QuickStatsSection(
                    assessmentCount: viewModel.recentAssessmentCount,
                    levelProgress: viewModel.levelProgress
                )
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Turn Lab")
        .task {
            await viewModel.loadData()
        }
        .refreshable {
            await viewModel.loadData()
        }
    }
}

struct QuickStatsSection: View {
    let assessmentCount: Int
    let levelProgress: Double

    var body: some View {
        ContentCard(title: "This Week", icon: "chart.bar.fill") {
            HStack(spacing: TurnLabSpacing.lg) {
                StatItem(
                    value: "\(assessmentCount)",
                    label: "Assessments",
                    icon: "checkmark.circle"
                )

                Divider()

                StatItem(
                    value: "\(Int(levelProgress * 100))%",
                    label: "Level Progress",
                    icon: "arrow.up.right"
                )
            }
        }
    }
}

struct StatItem: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: TurnLabSpacing.xxs) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text(value)
                    .font(TurnLabTypography.statValue)
            }
            .foregroundStyle(Color.accentColor)

            Text(label)
                .font(TurnLabTypography.caption)
                .foregroundStyle(TurnLabColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        HomeView(
            viewModel: HomeViewModel(
                skillRepository: SkillRepository(contentManager: ContentManager()),
                assessmentRepository: AssessmentRepository(coreDataStack: .preview),
                progressionService: ProgressionService(
                    skillRepository: SkillRepository(contentManager: ContentManager()),
                    assessmentRepository: AssessmentRepository(coreDataStack: .preview)
                ),
                appState: AppState()
            )
        )
    }
}
