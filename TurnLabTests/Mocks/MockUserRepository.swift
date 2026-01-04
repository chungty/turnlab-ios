import Foundation
@testable import TurnLab

/// Mock implementation of UserRepositoryProtocol for testing.
final class MockUserRepository: UserRepositoryProtocol {
    // MARK: - State

    var currentLevel: SkillLevel = .beginner
    var focusSkillId: String?
    var isPremium: Bool = false
    var notificationsEnabled: Bool = true

    // MARK: - Call Tracking

    private(set) var getCurrentLevelCalled = false
    private(set) var setCurrentLevelCallCount = 0
    private(set) var lastSetLevel: SkillLevel?
    private(set) var getFocusSkillIdCalled = false
    private(set) var setFocusSkillIdCallCount = 0
    private(set) var lastSetFocusSkillId: String?

    // MARK: - UserRepositoryProtocol

    func getCurrentLevel() -> SkillLevel {
        getCurrentLevelCalled = true
        return currentLevel
    }

    func setCurrentLevel(_ level: SkillLevel) {
        setCurrentLevelCallCount += 1
        lastSetLevel = level
        currentLevel = level
    }

    func getFocusSkillId() -> String? {
        getFocusSkillIdCalled = true
        return focusSkillId
    }

    func setFocusSkillId(_ id: String?) {
        setFocusSkillIdCallCount += 1
        lastSetFocusSkillId = id
        focusSkillId = id
    }

    func getIsPremium() -> Bool {
        return isPremium
    }

    func setIsPremium(_ premium: Bool) {
        isPremium = premium
    }

    func getNotificationsEnabled() -> Bool {
        return notificationsEnabled
    }

    func setNotificationsEnabled(_ enabled: Bool) {
        notificationsEnabled = enabled
    }

    // MARK: - Test Helpers

    func reset() {
        currentLevel = .beginner
        focusSkillId = nil
        isPremium = false
        notificationsEnabled = true
        getCurrentLevelCalled = false
        setCurrentLevelCallCount = 0
        lastSetLevel = nil
        getFocusSkillIdCalled = false
        setFocusSkillIdCallCount = 0
        lastSetFocusSkillId = nil
    }
}
