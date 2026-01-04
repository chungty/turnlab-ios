import SwiftUI

/// ViewModel for the home dashboard.
@MainActor
final class HomeViewModel: ObservableObject {
    // MARK: - Published State
    @Published var focusSkill: Skill?
    @Published var focusSkillRating: Rating = .notAssessed
    @Published var suggestedSkills: [Skill] = []
    @Published var levelProgress: Double = 0
    @Published var recentAssessmentCount = 0
    @Published var isLoading = false

    // MARK: - Dependencies
    private let skillRepository: SkillRepositoryProtocol
    private let assessmentRepository: AssessmentRepositoryProtocol
    private let progressionService: ProgressionService
    private let appState: AppState

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
        appState: AppState
    ) {
        self.skillRepository = skillRepository
        self.assessmentRepository = assessmentRepository
        self.progressionService = progressionService
        self.appState = appState
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
        suggestedSkills = await progressionService.suggestedSkills(
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
