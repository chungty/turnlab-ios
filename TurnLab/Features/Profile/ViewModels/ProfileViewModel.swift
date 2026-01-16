import SwiftUI

/// ViewModel for user profile.
@MainActor
final class ProfileViewModel: ObservableObject {
    // MARK: - Published State
    @Published var statistics: ProgressStatistics?
    @Published var levelProgress: [SkillLevel: Double] = [:]
    @Published var domainProgress: [SkillDomain: Double] = [:]
    @Published var recentAssessments: [AssessmentEntity] = []
    @Published var isLoading = false

    // MARK: - Dependencies
    private let userRepository: UserRepositoryProtocol
    private let assessmentRepository: AssessmentRepositoryProtocol
    private let progressionService: ProgressionService
    private let appState: AppState

    // MARK: - Computed Properties
    var currentLevel: SkillLevel {
        appState.currentUserLevel
    }

    var isPremium: Bool {
        appState.isPremiumUnlocked
    }

    var totalAssessments: Int {
        statistics?.assessedSkills ?? 0
    }

    var confidentSkills: Int {
        statistics?.confidentSkills ?? 0
    }

    var completionPercentage: Double {
        statistics?.completionPercentage ?? 0
    }

    // MARK: - Initialization
    init(
        userRepository: UserRepositoryProtocol,
        assessmentRepository: AssessmentRepositoryProtocol,
        progressionService: ProgressionService,
        appState: AppState
    ) {
        self.userRepository = userRepository
        self.assessmentRepository = assessmentRepository
        self.progressionService = progressionService
        self.appState = appState
    }

    // MARK: - Data Loading
    func loadData() async {
        isLoading = true

        // Load statistics
        statistics = await progressionService.getStatistics()

        // Load level progress for each level
        for level in SkillLevel.allCases {
            levelProgress[level] = await progressionService.progressTowardNextLevel(
                currentLevel: level
            )
        }

        // Load domain progress
        await loadDomainProgress()

        // Load recent assessments
        recentAssessments = await assessmentRepository.getRecentAssessments(days: 30)

        isLoading = false
    }

    private func loadDomainProgress() async {
        // TODO: Use rating summary to calculate domain progress
        _ = await assessmentRepository.getSkillRatingSummary()

        for domain in SkillDomain.allCases {
            // This would need access to skills by domain
            // For now, set a placeholder
            domainProgress[domain] = 0.5
        }
    }

    // MARK: - Stats for Display
    func formattedProgress(for level: SkillLevel) -> String {
        let progress = levelProgress[level] ?? 0
        return "\(Int(progress * 100))%"
    }

    func progressColor(for level: SkillLevel) -> Color {
        let progress = levelProgress[level] ?? 0
        if progress >= SkillLevel.unlockThreshold {
            return .green
        } else if progress >= 0.5 {
            return .orange
        } else {
            return .blue
        }
    }
}
