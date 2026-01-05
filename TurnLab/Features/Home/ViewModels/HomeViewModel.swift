import SwiftUI
import Combine

/// ViewModel for the home dashboard.
@MainActor
final class HomeViewModel: ObservableObject {
    // MARK: - Published State
    @Published var focusSkill: Skill?
    @Published var focusSkillRating: Rating = .notAssessed
    @Published var suggestedSkills: [SuggestedSkillWithReason] = []
    @Published var levelProgress: Double = 0
    @Published var recentAssessmentCount = 0
    @Published var isLoading = false
    @Published var isContentLoading = true

    // MARK: - Dependencies
    private let skillRepository: SkillRepositoryProtocol
    private let assessmentRepository: AssessmentRepositoryProtocol
    private let progressionService: ProgressionService
    private let appState: AppState
    private let contentManager: ContentManager
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Computed Properties
    var currentLevel: SkillLevel {
        appState.currentUserLevel
    }

    var canAdvanceLevel: Bool {
        levelProgress >= SkillLevel.unlockThreshold
    }

    var nextLevel: SkillLevel? {
        progressionService.nextLevel(from: currentLevel)
    }

    // MARK: - Initialization
    init(
        skillRepository: SkillRepositoryProtocol,
        assessmentRepository: AssessmentRepositoryProtocol,
        progressionService: ProgressionService,
        appState: AppState,
        contentManager: ContentManager
    ) {
        self.skillRepository = skillRepository
        self.assessmentRepository = assessmentRepository
        self.progressionService = progressionService
        self.appState = appState
        self.contentManager = contentManager

        // Observe content loading state
        contentManager.$isLoaded
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoaded in
                self?.isContentLoading = !isLoaded
                if isLoaded {
                    Task { [weak self] in
                        await self?.loadData()
                    }
                }
            }
            .store(in: &cancellables)

        // Check if content is already loaded
        if contentManager.isLoaded {
            isContentLoading = false
        }
    }

    // MARK: - Data Loading
    func loadData() async {
        isLoading = true

        async let focusSkillTask = loadFocusSkill()
        async let progressTask = loadLevelProgress()
        async let suggestedTask = loadSuggestedSkills()
        async let recentTask = loadRecentAssessments()

        _ = await (focusSkillTask, progressTask, suggestedTask, recentTask)

        isLoading = false
    }

    private func loadFocusSkill() async {
        if let skillId = appState.focusSkillId {
            focusSkill = await skillRepository.getSkill(id: skillId)
            if let skill = focusSkill {
                focusSkillRating = await progressionService.overallRating(for: skill.id)
            }
        } else {
            // Auto-select first suggested skill if no focus
            let suggested = await progressionService.suggestedSkills(
                currentLevel: currentLevel,
                limit: 1
            )
            if let first = suggested.first {
                focusSkill = first
                focusSkillRating = await progressionService.overallRating(for: first.id)
            }
        }
    }

    private func loadLevelProgress() async {
        levelProgress = await progressionService.progressTowardNextLevel(
            currentLevel: currentLevel
        )
    }

    private func loadSuggestedSkills() async {
        suggestedSkills = await progressionService.suggestedSkillsWithReasons(
            currentLevel: currentLevel,
            limit: 3
        )
    }

    private func loadRecentAssessments() async {
        let recent = await assessmentRepository.getRecentAssessments(days: 7)
        recentAssessmentCount = recent.count
    }

    // MARK: - Actions
    func setFocusSkill(_ skill: Skill) {
        appState.setFocusSkill(skill.id)
        focusSkill = skill
        Task {
            focusSkillRating = await progressionService.overallRating(for: skill.id)
        }
    }

    func clearFocusSkill() {
        appState.setFocusSkill(nil)
        focusSkill = nil
        focusSkillRating = .notAssessed
    }
}
