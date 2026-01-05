import Foundation
@testable import TurnLab

/// Mock implementation of UserRepositoryProtocol for testing.
final class MockUserRepository: UserRepositoryProtocol {
    // MARK: - State

    var currentUser: UserEntity?
    var currentLevel: SkillLevel = .beginner
    var focusSkillId: String?
    var isPremium: Bool = false
    var notificationsEnabled: Bool = true
    var onboardingComplete: Bool = false

    // MARK: - Call Tracking

    private(set) var getCurrentUserCalled = false
    private(set) var createUserCallCount = 0
    private(set) var updateLevelCallCount = 0
    private(set) var updateFocusSkillCallCount = 0
    private(set) var saveQuizResultCallCount = 0
    private(set) var lastSetLevel: SkillLevel?
    private(set) var lastSetFocusSkillId: String?
    private(set) var lastQuizResult: QuizResult?

    // MARK: - UserRepositoryProtocol

    func getCurrentUser() async -> UserEntity? {
        getCurrentUserCalled = true
        return currentUser
    }

    func createUser(level: SkillLevel) async -> UserEntity {
        createUserCallCount += 1
        currentLevel = level
        onboardingComplete = true
        // Return a mock entity - in real tests you'd use a proper Core Data setup
        fatalError("MockUserRepository.createUser() needs proper Core Data stack for testing")
    }

    func updateUserLevel(_ level: SkillLevel) async {
        updateLevelCallCount += 1
        lastSetLevel = level
        currentLevel = level
    }

    func updateFocusSkill(_ skillId: String?) async {
        updateFocusSkillCallCount += 1
        lastSetFocusSkillId = skillId
        focusSkillId = skillId
    }

    func getPreferences() async -> PreferencesEntity? {
        return nil
    }

    func updatePremiumStatus(unlocked: Bool) async {
        isPremium = unlocked
    }

    func updateNotificationPreference(enabled: Bool) async {
        notificationsEnabled = enabled
    }

    func saveQuizResult(_ result: QuizResult) async {
        saveQuizResultCallCount += 1
        lastQuizResult = result
        onboardingComplete = true
    }

    func isOnboardingComplete() async -> Bool {
        return onboardingComplete
    }

    // MARK: - Test Helpers

    func reset() {
        currentUser = nil
        currentLevel = .beginner
        focusSkillId = nil
        isPremium = false
        notificationsEnabled = true
        onboardingComplete = false
        getCurrentUserCalled = false
        createUserCallCount = 0
        updateLevelCallCount = 0
        updateFocusSkillCallCount = 0
        saveQuizResultCallCount = 0
        lastSetLevel = nil
        lastSetFocusSkillId = nil
        lastQuizResult = nil
    }
}
