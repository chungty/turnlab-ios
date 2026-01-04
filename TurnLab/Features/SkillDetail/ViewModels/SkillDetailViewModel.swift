import SwiftUI

/// ViewModel for skill detail view.
@MainActor
final class SkillDetailViewModel: ObservableObject {
    // MARK: - Published State
    @Published var skill: Skill?
    @Published var assessments: [AssessmentEntity] = []
    @Published var overallRating: Rating = .notAssessed
    @Published var contextRatings: [TerrainContext: Rating] = [:]
    @Published var prerequisites: [Skill] = []
    @Published var prerequisitesMet = true
    @Published var selectedContentTab: ContentTab = .videos
    @Published var isLoading = false
    @Published var isFocusSkill = false

    enum ContentTab: String, CaseIterable {
        case videos = "Videos"
        case tips = "Tips"
        case drills = "Drills"
    }

    // MARK: - Dependencies
    private let skillId: String
    private let skillRepository: SkillRepositoryProtocol
    private let assessmentRepository: AssessmentRepositoryProtocol
    private let appState: AppState

    // MARK: - Computed Properties
    var isLocked: Bool {
        guard let skill else { return true }
        return !appState.canAccessLevel(skill.level)
    }

    var videos: [VideoReference] {
        skill?.content.videos ?? []
    }

    var tips: [Tip] {
        skill?.content.tips ?? []
    }

    var quickTips: [Tip] {
        tips.filter { $0.isQuickReference }
    }

    var drills: [Drill] {
        skill?.content.drills ?? []
    }

    var checklists: [Checklist] {
        skill?.content.checklists ?? []
    }

    var warnings: [SafetyWarning] {
        skill?.content.warnings ?? []
    }

    // MARK: - Initialization
    init(
        skillId: String,
        skillRepository: SkillRepositoryProtocol,
        assessmentRepository: AssessmentRepositoryProtocol,
        appState: AppState
    ) {
        self.skillId = skillId
        self.skillRepository = skillRepository
        self.assessmentRepository = assessmentRepository
        self.appState = appState
    }

    // MARK: - Data Loading
    func loadData() async {
        isLoading = true

        // Load skill
        skill = await skillRepository.getSkill(id: skillId)

        guard let skill else {
            isLoading = false
            return
        }

        // Load assessments
        assessments = await assessmentRepository.getAssessments(for: skillId)

        // Calculate overall rating
        overallRating = await assessmentRepository.getBestRating(for: skillId)

        // Load context-specific ratings
        for context in skill.assessmentContexts {
            if let assessment = await assessmentRepository.getLatestAssessment(
                for: skillId,
                context: context
            ) {
                contextRatings[context] = assessment.ratingValue
            }
        }

        // Load prerequisites
        prerequisites = await skillRepository.getPrerequisites(for: skillId)

        // Check if prerequisites are met
        let ratingSummary = await assessmentRepository.getSkillRatingSummary()
        prerequisitesMet = skill.prerequisites.allSatisfy { prereqId in
            guard let rating = ratingSummary[prereqId] else { return false }
            return rating >= .developing
        }

        // Check if this is the focus skill
        isFocusSkill = appState.focusSkillId == skillId

        isLoading = false
    }

    // MARK: - Actions
    func setAsFocusSkill() {
        appState.setFocusSkill(skillId)
        isFocusSkill = true
    }

    func removeFocusSkill() {
        appState.setFocusSkill(nil)
        isFocusSkill = false
    }

    func refreshAssessments() async {
        assessments = await assessmentRepository.getAssessments(for: skillId)
        overallRating = await assessmentRepository.getBestRating(for: skillId)

        if let skill {
            for context in skill.assessmentContexts {
                if let assessment = await assessmentRepository.getLatestAssessment(
                    for: skillId,
                    context: context
                ) {
                    contextRatings[context] = assessment.ratingValue
                }
            }
        }
    }
}
