import SwiftUI
import Combine

/// ViewModel for the onboarding quiz flow.
@MainActor
final class OnboardingViewModel: ObservableObject {
    // MARK: - Published State
    @Published var questions: [QuizQuestion] = []
    @Published var currentQuestionIndex = 0
    @Published var answers: [String: String] = [:] // QuestionID -> OptionID
    @Published var isCompleted = false
    @Published var result: QuizResult?
    @Published var isLoading = false
    @Published var isContentLoading = true

    // MARK: - Dependencies
    private let contentManager: ContentManager
    private let userRepository: UserRepositoryProtocol
    private let appState: AppState
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Computed Properties
    var currentQuestion: QuizQuestion? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }

    var progress: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentQuestionIndex) / Double(questions.count)
    }

    var canGoBack: Bool {
        currentQuestionIndex > 0
    }

    var canGoNext: Bool {
        guard let question = currentQuestion else { return false }
        return answers[question.id] != nil
    }

    var isLastQuestion: Bool {
        currentQuestionIndex == questions.count - 1
    }

    // MARK: - Initialization
    init(
        contentManager: ContentManager,
        userRepository: UserRepositoryProtocol,
        appState: AppState
    ) {
        self.contentManager = contentManager
        self.userRepository = userRepository
        self.appState = appState

        // Observe content loading state
        contentManager.$isLoaded
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoaded in
                self?.isContentLoading = !isLoaded
                if isLoaded {
                    self?.loadQuestions()
                }
            }
            .store(in: &cancellables)

        // Load immediately if already loaded
        if contentManager.isLoaded {
            isContentLoading = false
            loadQuestions()
        }
    }

    // MARK: - Actions
    func loadQuestions() {
        questions = contentManager.sortedQuizQuestions
    }

    func selectAnswer(_ optionId: String) {
        guard let question = currentQuestion else { return }
        answers[question.id] = optionId
    }

    func goToNextQuestion() {
        guard canGoNext else { return }

        if isLastQuestion {
            calculateResult()
        } else {
            currentQuestionIndex += 1
        }
    }

    func goToPreviousQuestion() {
        guard canGoBack else { return }
        currentQuestionIndex -= 1
    }

    func skipToEnd() {
        // Default to beginner if skipping
        let defaultResult = QuizResult(
            recommendedLevel: .beginner,
            levelScores: [.beginner: 0],
            completedAt: Date(),
            answers: [:]
        )
        completeOnboarding(with: defaultResult)
    }

    // MARK: - Private Methods
    private func calculateResult() {
        isLoading = true

        // Calculate scores for each level
        var levelScores: [SkillLevel: Int] = [:]
        for level in SkillLevel.allCases {
            levelScores[level] = 0
        }

        // Sum up points from all answers
        for (questionId, optionId) in answers {
            guard let question = questions.first(where: { $0.id == questionId }),
                  let option = question.options.first(where: { $0.id == optionId }) else {
                continue
            }

            for level in SkillLevel.allCases {
                levelScores[level, default: 0] += option.points(for: level)
            }
        }

        // Find the level with the highest score
        let recommendedLevel = levelScores.max(by: { $0.value < $1.value })?.key ?? .beginner

        let quizResult = QuizResult(
            recommendedLevel: recommendedLevel,
            levelScores: levelScores,
            completedAt: Date(),
            answers: answers
        )

        result = quizResult
        isCompleted = true
        isLoading = false
    }

    func completeOnboarding(with result: QuizResult) {
        Task {
            isLoading = true

            // Create user with recommended level
            _ = await userRepository.createUser(level: result.recommendedLevel)

            // Save quiz result
            await userRepository.saveQuizResult(result)

            // Update app state
            appState.completeOnboarding(withLevel: result.recommendedLevel)

            isLoading = false
        }
    }

    func acceptRecommendedLevel() {
        guard let result else { return }
        completeOnboarding(with: result)
    }

    func selectDifferentLevel(_ level: SkillLevel) {
        let adjustedResult = QuizResult(
            recommendedLevel: level,
            levelScores: result?.levelScores ?? [:],
            completedAt: Date(),
            answers: answers
        )
        completeOnboarding(with: adjustedResult)
    }
}
