import SwiftUI

/// User profile view showing progress and statistics.
struct ProfileView: View {
    @StateObject private var viewModel: ProfileViewModel

    init(viewModel: ProfileViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: TurnLabSpacing.lg) {
                // Header
                ProfileHeaderSection(
                    level: viewModel.currentLevel,
                    isPremium: viewModel.isPremium
                )

                // Level progression
                LevelProgressionSection(
                    levelProgress: viewModel.levelProgress,
                    currentLevel: viewModel.currentLevel
                )

                // Domain radar chart
                if !viewModel.domainProgress.isEmpty {
                    DomainRadarChart(domainProgress: viewModel.domainProgress)
                }

                // Statistics grid
                StatsGridSection(
                    totalAssessments: viewModel.totalAssessments,
                    confidentSkills: viewModel.confidentSkills,
                    completionPercentage: viewModel.completionPercentage
                )

                // Recent activity
                RecentActivitySection(assessments: viewModel.recentAssessments)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Profile")
        .task {
            await viewModel.loadData()
        }
        .refreshable {
            await viewModel.loadData()
        }
    }
}

struct ProfileHeaderSection: View {
    let level: SkillLevel
    let isPremium: Bool

    var body: some View {
        VStack(spacing: TurnLabSpacing.sm) {
            // Avatar/icon
            ZStack {
                Circle()
                    .fill(TurnLabColors.levelColor(level).opacity(0.2))
                    .frame(width: 80, height: 80)

                Image(systemName: "figure.skiing.downhill")
                    .font(.system(size: 36))
                    .foregroundStyle(TurnLabColors.levelColor(level))
            }

            // Level
            VStack(spacing: TurnLabSpacing.xxs) {
                LevelBadge(level: level, size: .large)

                if isPremium {
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .foregroundStyle(.yellow)
                        Text("Premium")
                            .foregroundStyle(TurnLabColors.textSecondary)
                    }
                    .font(.caption)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: TurnLabSpacing.cornerRadiusLarge))
    }
}

struct RecentActivitySection: View {
    let assessments: [AssessmentEntity]

    var body: some View {
        ContentCard(title: "Recent Activity", subtitle: "Last 30 days", icon: "clock") {
            if assessments.isEmpty {
                Text("No recent assessments")
                    .font(TurnLabTypography.body)
                    .foregroundStyle(TurnLabColors.textTertiary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                VStack(spacing: TurnLabSpacing.xs) {
                    ForEach(assessments.prefix(5), id: \.id) { assessment in
                        HStack {
                            Circle()
                                .fill(assessment.ratingValue.color)
                                .frame(width: 8, height: 8)

                            Text(assessment.skillId)
                                .font(TurnLabTypography.caption)
                                .foregroundStyle(TurnLabColors.textPrimary)
                                .lineLimit(1)

                            Spacer()

                            Text(assessment.date, style: .relative)
                                .font(.caption2)
                                .foregroundStyle(TurnLabColors.textTertiary)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView(
            viewModel: ProfileViewModel(
                userRepository: UserRepository(coreDataStack: .preview),
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
