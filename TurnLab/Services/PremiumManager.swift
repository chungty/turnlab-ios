import Foundation

/// Manages premium feature access and purchase state.
@MainActor
final class PremiumManager: ObservableObject {
    @Published private(set) var isPremiumUnlocked = false
    @Published private(set) var isLoading = false

    private let userRepository: UserRepositoryProtocol
    private let purchaseService: PurchaseService

    // MARK: - Fair Access Model

    /// Number of free skills granted at each assessed level (5/2/2/1 model)
    /// - Beginner: All 5 beginner skills free (no bonus needed)
    /// - Novice: 2 novice skills free as bonus
    /// - Intermediate: 2 intermediate skills free as bonus
    /// - Expert: 1 expert skill free as teaser
    static let freeSkillsPerLevel: [SkillLevel: Int] = [
        .beginner: 0,      // All beginner skills are free anyway
        .novice: 2,        // 2 free novice skills
        .intermediate: 2,  // 2 free intermediate skills
        .expert: 1         // 1 free expert skill (teaser)
    ]

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
