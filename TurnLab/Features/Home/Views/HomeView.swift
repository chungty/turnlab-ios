import SwiftUI

/// Main dashboard view.
struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @EnvironmentObject private var container: DIContainer

    /// State for showing the welcome back card for returning users.
    @State private var showWelcomeBack = false

    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            if viewModel.isContentLoading {
                // Loading state while content loads
                ZStack {
                    MountainBackgroundView(style: .day)
                    VStack(spacing: TurnLabSpacing.lg) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                        Text("Loading your ski journey...")
                            .font(TurnLabTypography.body)
                            .foregroundColor(.white)
                    }
                }
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        // Immersive header with mountain gradient
                        HomeHeaderView(
                            level: viewModel.currentLevel,
                            progress: viewModel.levelProgress,
                            userName: "Skier"
                        )

                        VStack(spacing: TurnLabSpacing.lg) {
                            // Welcome back card for returning users (>24 hours since last visit)
                            if showWelcomeBack {
                                WelcomeBackCard(
                                    lastVisit: container.appState.lastVisitDate,
                                    focusSkillName: viewModel.focusSkill?.name,
                                    currentRating: viewModel.focusSkillRating,
                                    onContinue: {
                                        // Navigate to focus skill if one is set
                                        if let focusSkill = viewModel.focusSkill {
                                            container.appState.navigateToSkill(focusSkill.id)
                                        }
                                    },
                                    onDismiss: {
                                        withAnimation {
                                            showWelcomeBack = false
                                        }
                                    }
                                )
                            }

                            // Level progress card
                            LevelProgressCard(
                                level: viewModel.currentLevel,
                                progress: viewModel.levelProgress,
                                canAdvance: viewModel.canAdvanceLevel,
                                nextLevel: viewModel.nextLevel,
                                onAdvance: {
                                    Task {
                                        await viewModel.advanceToNextLevel()
                                    }
                                }
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
                                    suggestions: viewModel.suggestedSkills,
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
                }
                .background(Color(.systemGroupedBackground))
            }
        }
        .navigationTitle("Turn Lab")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("home_view")
        .task {
            await viewModel.loadData()
        }
        .refreshable {
            await viewModel.loadData()
        }
        .onAppear {
            // Check if we should show welcome back card (>24 hours since last visit)
            if container.appState.shouldShowWelcomeBack() {
                showWelcomeBack = true
            }
            // Record this visit for next time
            container.appState.recordVisit()
        }
    }
}

// MARK: - Immersive Header View
struct HomeHeaderView: View {
    let level: SkillLevel
    let progress: Double
    let userName: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Mountain gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.15, green: 0.35, blue: 0.55),
                    Color(red: 0.25, green: 0.50, blue: 0.70),
                    Color(red: 0.40, green: 0.65, blue: 0.85)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Mountain silhouette
            MountainSilhouette()
                .fill(Color.white.opacity(0.1))
                .offset(y: 20)

            // Content
            VStack(alignment: .leading, spacing: TurnLabSpacing.xs) {
                Text(greetingText)
                    .font(TurnLabTypography.title2)
                    .foregroundColor(.white.opacity(0.9))

                HStack(spacing: TurnLabSpacing.sm) {
                    Image(systemName: levelIcon)
                        .font(.system(size: 24))
                        .foregroundColor(.white)

                    Text("\(level.displayName) Skier")
                        .font(TurnLabTypography.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }

                Text(motivationalText)
                    .font(TurnLabTypography.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding()
            .padding(.bottom, TurnLabSpacing.md)
        }
        .frame(height: 180)
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }

    private var levelIcon: String {
        switch level {
        case .beginner: return "figure.skiing.downhill"
        case .novice: return "figure.skiing.downhill"
        case .intermediate: return "mountain.2"
        case .expert: return "snowflake"
        }
    }

    private var motivationalText: String {
        let percentage = Int(progress * 100)
        if percentage < 30 {
            return "Every run builds your foundation"
        } else if percentage < 60 {
            return "Great progress! Keep pushing"
        } else if percentage < 80 {
            return "Almost there - stay focused"
        } else {
            return "Ready to advance!"
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
    let contentManager = ContentManager()
    return NavigationStack {
        HomeView(
            viewModel: HomeViewModel(
                skillRepository: SkillRepository(contentManager: contentManager),
                assessmentRepository: AssessmentRepository(coreDataStack: .preview),
                progressionService: ProgressionService(
                    skillRepository: SkillRepository(contentManager: contentManager),
                    assessmentRepository: AssessmentRepository(coreDataStack: .preview)
                ),
                appState: AppState(),
                contentManager: contentManager
            )
        )
    }
}
