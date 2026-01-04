import Foundation

/// Manages premium feature access and purchase state.
@MainActor
final class PremiumManager: ObservableObject {
    @Published private(set) var isPremiumUnlocked = false
    @Published private(set) var isLoading = false

    private let userRepository: UserRepositoryProtocol
    private let purchaseService: PurchaseService

    init(
        userRepository: UserRepositoryProtocol,
        purchaseService: PurchaseService
    ) {
        self.userRepository = userRepository
        self.purchaseService = purchaseService
    }

    // MARK: - Status Check

    func checkPremiumStatus() async -> Bool {
        // First check local storage
        if let prefs = await userRepository.getPreferences() {
            if prefs.isPremiumUnlocked {
                isPremiumUnlocked = true
                return true
            }
        }

        // Then verify with StoreKit
        let purchased = await purchaseService.isPremiumPurchased()
        if purchased {
            await userRepository.updatePremiumStatus(unlocked: true)
            isPremiumUnlocked = true
        }

        return purchased
    }

    // MARK: - Access Control

    func canAccessLevel(_ level: SkillLevel) -> Bool {
        if level == .beginner { return true }
        return isPremiumUnlocked
    }

    func canAccessSkill(_ skill: Skill) -> Bool {
        canAccessLevel(skill.level)
    }

    // MARK: - Purchase

    func purchasePremium() async throws {
        isLoading = true
        defer { isLoading = false }

        try await purchaseService.purchase()

        // Update local storage
        await userRepository.updatePremiumStatus(unlocked: true)
        isPremiumUnlocked = true
    }

    // MARK: - Restore

    func restorePurchases() async throws {
        isLoading = true
        defer { isLoading = false }

        try await purchaseService.restore()

        let purchased = await purchaseService.isPremiumPurchased()
        if purchased {
            await userRepository.updatePremiumStatus(unlocked: true)
            isPremiumUnlocked = true
        }
    }
}
