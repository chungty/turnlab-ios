import SwiftUI

/// Container view for the onboarding quiz flow.
struct OnboardingContainerView: View {
    @StateObject private var viewModel: OnboardingViewModel
    @EnvironmentObject private var container: DIContainer

    init(viewModel: OnboardingViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            // Background
            MountainBackgroundView(style: .day)

            // Content
            if viewModel.isContentLoading {
                // Loading state while content loads
                VStack(spacing: TurnLabSpacing.lg) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                        .accessibilityIdentifier("onboarding_loading_indicator")

                    Text("Preparing your assessment...")
                        .font(TurnLabTypography.body)
                        .foregroundColor(.white)
                }
                .accessibilityIdentifier("onboarding_loading_view")
            } else {
                VStack(spacing: 0) {
                    if viewModel.isCompleted {
                        QuizResultView(viewModel: viewModel)
                    } else {
                        // Progress bar
                        QuizProgressBar(progress: viewModel.progress)
                            .padding(.horizontal)
                            .padding(.top)

                        // Question
                        if let question = viewModel.currentQuestion {
                            QuizQuestionView(
                                question: question,
                                selectedOptionId: viewModel.answers[question.id],
                                onSelect: { viewModel.selectAnswer($0) }
                            )
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                            .id(question.id)
                        } else {
                            // Fallback if no questions available (shouldn't happen)
                            VStack(spacing: TurnLabSpacing.md) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.system(size: 48))
                                    .foregroundColor(.orange)

                                Text("Unable to load quiz questions")
                                    .font(TurnLabTypography.headline)
                                    .foregroundColor(.white)

                                Text("Please restart the app")
                                    .font(TurnLabTypography.body)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            .padding()
                        }

                        Spacer()

                        // Navigation buttons
                        if viewModel.currentQuestion != nil {
                            HStack(spacing: TurnLabSpacing.md) {
                                if viewModel.canGoBack {
                                    SecondaryButton(
                                        title: "Back",
                                        icon: "chevron.left",
                                        accessibilityId: "quiz_back_button"
                                    ) {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            viewModel.goToPreviousQuestion()
                                        }
                                    }
                                }

                                PrimaryButton(
                                    title: viewModel.isLastQuestion ? "Finish" : "Next",
                                    icon: viewModel.isLastQuestion ? "checkmark" : "chevron.right",
                                    isDisabled: !viewModel.canGoNext,
                                    accessibilityId: viewModel.isLastQuestion ? "quiz_finish_button" : "quiz_next_button"
                                ) {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        viewModel.goToNextQuestion()
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
            }

            // Loading overlay
            if viewModel.isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.5)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.isCompleted)
        .animation(.easeInOut(duration: 0.3), value: viewModel.isContentLoading)
    }
}

#Preview {
    OnboardingContainerView(
        viewModel: OnboardingViewModel(
            contentManager: ContentManager(),
            userRepository: UserRepository(coreDataStack: .preview),
            appState: AppState()
        )
    )
}
