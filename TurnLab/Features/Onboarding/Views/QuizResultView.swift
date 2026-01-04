import SwiftUI

/// Displays quiz results and recommended starting level.
struct QuizResultView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: TurnLabSpacing.xl) {
                // Header
                VStack(spacing: TurnLabSpacing.sm) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(.green)

                    Text("Assessment Complete!")
                        .font(TurnLabTypography.title1)
                        .foregroundStyle(.white)
                }
                .padding(.top, TurnLabSpacing.xxl)

                // Recommended level
                if let result = viewModel.result {
                    VStack(spacing: TurnLabSpacing.md) {
                        Text("Your recommended starting level:")
                            .font(TurnLabTypography.body)
                            .foregroundStyle(.white.opacity(0.8))

                        LevelBadge(level: result.recommendedLevel, size: .large)

                        Text(result.recommendedLevel.description)
                            .font(TurnLabTypography.callout)
                            .foregroundStyle(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: TurnLabSpacing.cornerRadiusLarge))
                    .padding(.horizontal)

                    // Confidence indicator
                    HStack {
                        Image(systemName: "chart.bar.fill")
                        Text("Confidence: \(Int(result.confidence * 100))%")
                    }
                    .font(TurnLabTypography.caption)
                    .foregroundStyle(.white.opacity(0.6))
                }

                Spacer(minLength: TurnLabSpacing.xl)

                // Actions
                VStack(spacing: TurnLabSpacing.sm) {
                    PrimaryButton(
                        title: "Start at This Level",
                        icon: "arrow.right",
                        isLoading: viewModel.isLoading
                    ) {
                        viewModel.acceptRecommendedLevel()
                    }

                    // Alternative level selection
                    Text("Or choose a different level:")
                        .font(TurnLabTypography.caption)
                        .foregroundStyle(.white.opacity(0.6))
                        .padding(.top)

                    HStack(spacing: TurnLabSpacing.xs) {
                        ForEach(SkillLevel.allCases, id: \.self) { level in
                            if level != viewModel.result?.recommendedLevel {
                                Button(action: { viewModel.selectDifferentLevel(level) }) {
                                    Text(level.displayName)
                                        .font(TurnLabTypography.caption)
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, TurnLabSpacing.sm)
                                        .padding(.vertical, TurnLabSpacing.xs)
                                        .background(TurnLabColors.levelColor(level).opacity(0.5))
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
    }
}

#Preview {
    ZStack {
        MountainBackgroundView()

        QuizResultView(
            viewModel: {
                let vm = OnboardingViewModel(
                    contentManager: ContentManager(),
                    userRepository: UserRepository(coreDataStack: .preview),
                    appState: AppState()
                )
                vm.result = QuizResult(
                    recommendedLevel: .novice,
                    levelScores: [.beginner: 2, .novice: 5, .intermediate: 3, .expert: 1],
                    completedAt: Date(),
                    answers: [:]
                )
                vm.isCompleted = true
                return vm
            }()
        )
    }
}
