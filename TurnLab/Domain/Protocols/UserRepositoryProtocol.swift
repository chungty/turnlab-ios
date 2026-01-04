import Foundation

/// Protocol for user data persistence.
protocol UserRepositoryProtocol {
    /// Get the current user, or nil if not yet created
    func getCurrentUser() async -> UserEntity?

    /// Create a new user with initial level
    func createUser(level: SkillLevel) async -> UserEntity

    /// Update user's current level
    func updateUserLevel(_ level: SkillLevel) async

    /// Update user's focus skill
    func updateFocusSkill(_ skillId: String?) async

    /// Get user preferences
    func getPreferences() async -> PreferencesEntity?

    /// Update premium status
    func updatePremiumStatus(unlocked: Bool) async

    /// Update notification preference
    func updateNotificationPreference(enabled: Bool) async

    /// Save quiz result
    func saveQuizResult(_ result: QuizResult) async

    /// Check if onboarding is complete
    func isOnboardingComplete() async -> Bool
}
