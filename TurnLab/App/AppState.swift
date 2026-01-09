import SwiftUI
import Combine

/// Global application state observable across the app.
@MainActor
final class AppState: ObservableObject {
    // MARK: - Published State
    @Published var isOnboardingComplete: Bool
    @Published var isPremiumUnlocked: Bool
    @Published var currentUserLevel: SkillLevel
    @Published var focusSkillId: String?

    /// Skill IDs that have been granted free access based on user's assessed level.
    /// Part of the Fair Access Model (5/2/2/1 free skills).
    @Published var grantedFreeSkillIds: Set<String>

    /// Date of user's last visit, used for "Welcome Back" messaging.
    /// Persisted to UserDefaults for simplicity.
    @Published var lastVisitDate: Date? {
        didSet {
            if let date = lastVisitDate {
                UserDefaults.standard.set(date, forKey: "lastVisitDate")
            }
        }
    }

    // MARK: - Navigation State
    @Published var selectedTab: Tab = .home
    @Published var navigationPath = NavigationPath()

    enum Tab: Hashable {
        case home
        case skills
        case profile
    }

    // MARK: - Initialization
    init(
        isOnboardingComplete: Bool = false,
        isPremiumUnlocked: Bool = false,
        currentUserLevel: SkillLevel = .beginner,
        focusSkillId: String? = nil,
        grantedFreeSkillIds: Set<String> = [],
        lastVisitDate: Date? = nil
    ) {
        self.isOnboardingComplete = isOnboardingComplete
        self.isPremiumUnlocked = isPremiumUnlocked
        self.currentUserLevel = currentUserLevel
        self.focusSkillId = focusSkillId
        self.grantedFreeSkillIds = grantedFreeSkillIds
        // Load last visit date from UserDefaults if not provided
        self.lastVisitDate = lastVisitDate ?? UserDefaults.standard.object(forKey: "lastVisitDate") as? Date
    }

    // MARK: - State Management
    func completeOnboarding(withLevel level: SkillLevel) {
        currentUserLevel = level
        isOnboardingComplete = true
    }

    func unlockPremium() {
        isPremiumUnlocked = true
    }

    func setFocusSkill(_ skillId: String?) {
        focusSkillId = skillId
    }

    func advanceLevel(to level: SkillLevel) {
        guard level > currentUserLevel else { return }
        currentUserLevel = level
    }

    /// Records the current date as the last visit date.
    /// Call this when the app becomes active or home screen appears.
    func recordVisit() {
        lastVisitDate = Date()
    }

    /// Checks if enough time has passed since last visit to show welcome back card.
    /// Returns true if more than 24 hours have passed.
    func shouldShowWelcomeBack() -> Bool {
        guard let lastVisit = lastVisitDate else { return false }
        return Date().timeIntervalSince(lastVisit) > 86400 // 24 hours
    }

    /// Grants free skills based on the user's assessed level (Fair Access Model).
    /// Called during onboarding to give users content at their level.
    /// - Parameters:
    ///   - level: The user's assessed skill level
    ///   - availableSkills: All skills in the content library
    func grantFreeSkillsForLevel(_ level: SkillLevel, availableSkills: [Skill]) {
        // Beginners get all beginner skills free by default, no bonus needed
        guard level != .beginner else {
            grantedFreeSkillIds = []
            return
        }

        // Get the count of free skills for this level
        let count = PremiumManager.freeSkillsPerLevel[level] ?? 0

        // Filter skills at the user's assessed level
        let eligibleSkills = availableSkills.filter { $0.level == level }

        // Grant the first N skills at their level
        // These are ordered by the content definition (typically easiest first)
        grantedFreeSkillIds = Set(eligibleSkills.prefix(count).map { $0.id })
    }

    /// Check if a specific skill has been granted free access
    func isSkillGrantedFree(_ skillId: String) -> Bool {
        grantedFreeSkillIds.contains(skillId)
    }

    /// Check if a skill level is accessible to the user
    func canAccessLevel(_ level: SkillLevel) -> Bool {
        if level == .beginner { return true }
        return isPremiumUnlocked
    }

    /// Check if a specific skill is accessible (includes granted free skills)
    func canAccessSkill(_ skill: Skill) -> Bool {
        // Premium users can access everything
        if isPremiumUnlocked { return true }
        // Beginner skills are always free
        if skill.level == .beginner { return true }
        // Check if this skill was granted free
        return isSkillGrantedFree(skill.id)
    }

    // MARK: - Navigation Helpers
    func navigateToSkill(_ skillId: String) {
        selectedTab = .skills
        navigationPath.append(Route.skillDetail(skillId: skillId))
    }

    func resetNavigation() {
        navigationPath = NavigationPath()
    }
}

// MARK: - Convenience Properties

extension AppState {
    /// Whether onboarding has been completed (alias for isOnboardingComplete)
    var hasCompletedOnboarding: Bool {
        get { isOnboardingComplete }
        set { isOnboardingComplete = newValue }
    }
}
