import SwiftUI
import Combine

/// ViewModel for the skill browser.
@MainActor
final class SkillBrowserViewModel: ObservableObject {
    // MARK: - Published State
    @Published var skills: [Skill] = []
    @Published var skillRatings: [String: Rating] = [:]
    @Published var searchQuery = ""
    @Published var selectedLevel: SkillLevel?
    @Published var selectedDomain: SkillDomain?
    @Published var viewMode: ViewMode = .byLevel
    @Published var isLoading = false
    @Published var isContentLoading = true

    enum ViewMode: String, CaseIterable {
        case byLevel = "By Level"
        case byDomain = "By Domain"
    }

    // MARK: - Dependencies
    private let skillRepository: SkillRepositoryProtocol
    private let assessmentRepository: AssessmentRepositoryProtocol
    private let appState: AppState
    private let contentManager: ContentManager
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Computed Properties
    var filteredSkills: [Skill] {
        var result = skills

        // Filter by search query
        if !searchQuery.isEmpty {
            let query = searchQuery.lowercased()
            result = result.filter {
                $0.name.lowercased().contains(query) ||
                $0.summary.lowercased().contains(query)
            }
        }

        // Filter by selected level
        if let level = selectedLevel {
            result = result.filter { $0.level == level }
        }

        // Filter by selected domain
        if let domain = selectedDomain {
            result = result.filter { $0.domains.contains(domain) }
        }

        return result
    }

    var skillsByLevel: [SkillLevel: [Skill]] {
        Dictionary(grouping: filteredSkills) { $0.level }
    }

    var skillsByDomain: [SkillDomain: [Skill]] {
        var result: [SkillDomain: [Skill]] = [:]
        for skill in filteredSkills {
            for domain in skill.domains {
                result[domain, default: []].append(skill)
            }
        }
        return result
    }

    var isPremium: Bool {
        appState.isPremiumUnlocked
    }

    // MARK: - Initialization
    init(
        skillRepository: SkillRepositoryProtocol,
        assessmentRepository: AssessmentRepositoryProtocol,
        appState: AppState,
        contentManager: ContentManager
    ) {
        self.skillRepository = skillRepository
        self.assessmentRepository = assessmentRepository
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

        skills = await skillRepository.getAllSkills()
        skillRatings = await assessmentRepository.getSkillRatingSummary()

        isLoading = false
    }

    // MARK: - Helpers
    func rating(for skill: Skill) -> Rating {
        skillRatings[skill.id] ?? .notAssessed
    }

    func isLocked(_ skill: Skill) -> Bool {
        // Use the Fair Access Model - check premium, beginner, and granted skills
        if isPremium { return false }
        if skill.level == .beginner { return false }
        if appState.isSkillGrantedFree(skill.id) { return false }
        return true
    }

    func canAccess(_ skill: Skill) -> Bool {
        // Use the skill-specific access check from AppState
        appState.canAccessSkill(skill)
    }

    // MARK: - Filters
    func clearFilters() {
        selectedLevel = nil
        selectedDomain = nil
        searchQuery = ""
    }

    func setLevelFilter(_ level: SkillLevel?) {
        selectedLevel = level
        selectedDomain = nil
    }

    func setDomainFilter(_ domain: SkillDomain?) {
        selectedDomain = domain
        selectedLevel = nil
    }
}
