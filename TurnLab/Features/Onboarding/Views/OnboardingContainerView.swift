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
                    }

                    Spacer()

                    // Navigation buttons
                    HStack(spacing: TurnLabSpacing.md) {
                        if viewModel.canGoBack {
                            SecondaryButton(title: "Back", icon: "chevron.left") {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    viewModel.goToPreviousQuestion()
                                }
                            }
                        }

                        PrimaryButton(
                            title: viewModel.isLastQuestion ? "Finish" : "Next",
                            icon: viewModel.isLastQuestion ? "checkmark" : "chevron.right",
                            isDisabled: !viewModel.canGoNext
                        ) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                viewModel.goToNextQuestion()
                            }
                        }
                    }
                    .padding()
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
