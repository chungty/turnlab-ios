import SwiftUI

/// ViewModel for assessment input.
@MainActor
final class AssessmentViewModel: ObservableObject {
    // MARK: - Published State
    @Published var skill: Skill?
    @Published var selectedContext: TerrainContext = .groomedBlue
    @Published var selectedRating: Rating = .notAssessed
    @Published var notes: String = ""
    @Published var existingRating: Rating?
    @Published var isSaving = false
    @Published var showSuccess = false

    // MARK: - Dependencies
    private let skillId: String
    private let skillRepository: SkillRepositoryProtocol
    private let assessmentRepository: AssessmentRepositoryProtocol
    private let progressionService: ProgressionService

    // MARK: - Computed Properties
    var availableContexts: [TerrainContext] {
        skill?.assessmentContexts ?? []
    }

    var milestones: Skill.OutcomeMilestones? {
        skill?.outcomeMilestones
    }

    var canSave: Bool {
        selectedRating != .notAssessed
    }

    var isImproved: Bool {
        guard let existing = existingRating else { return false }
        return selectedRating > existing
    }

    // MARK: - Initialization
    init(
        skillId: String,
        skillRepository: SkillRepositoryProtocol,
        assessmentRepository: AssessmentRepositoryProtocol,
        progressionService: ProgressionService
    ) {
        self.skillId = skillId
        self.skillRepository = skillRepository
        self.assessmentRepository = assessmentRepository
        self.progressionService = progressionService
    }

    // MARK: - Data Loading
    func loadData() async {
        skill = await skillRepository.getSkill(id: skillId)

        // Set default context
        if let firstContext = skill?.assessmentContexts.first {
            selectedContext = firstContext
            await loadExistingAssessment(for: firstContext)
        }
    }

    func loadExistingAssessment(for context: TerrainContext) async {
        if let assessment = await assessmentRepository.getLatestAssessment(
            for: skillId,
            context: context
        ) {
            existingRating = assessment.ratingValue
            // Pre-select the existing rating
            selectedRating = assessment.ratingValue
        } else {
            existingRating = nil
            selectedRating = .notAssessed
        }
    }

    // MARK: - Actions
    func selectContext(_ context: TerrainContext) {
        selectedContext = context
        Task {
            await loadExistingAssessment(for: context)
        }
    }

    func saveAssessment() async -> Bool {
        guard canSave else { return false }

        isSaving = true

        _ = await assessmentRepository.saveAssessment(
            skillId: skillId,
            context: selectedContext,
            rating: selectedRating,
            notes: notes.isEmpty ? nil : notes
        )

        isSaving = false
        showSuccess = true

        // Auto-dismiss success after delay
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        showSuccess = false

        return true
    }

    func reset() {
        selectedRating = existingRating ?? .notAssessed
        notes = ""
    }
}
