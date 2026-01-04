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
        focusSkillId: String? = nil
    ) {
        self.isOnboardingComplete = isOnboardingComplete
        self.isPremiumUnlocked = isPremiumUnlocked
        self.currentUserLevel = currentUserLevel
        self.focusSkillId = focusSkillId
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

    /// Check if a skill level is accessible to the user
    func canAccessLevel(_ level: SkillLevel) -> Bool {
        if level == .beginner { return true }
        return isPremiumUnlocked
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
