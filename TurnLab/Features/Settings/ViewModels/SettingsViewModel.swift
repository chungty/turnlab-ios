import SwiftUI

/// ViewModel for settings screen.
@MainActor
final class SettingsViewModel: ObservableObject {
    // MARK: - Published State
    @Published var isPremium: Bool = false
    @Published var notificationsEnabled: Bool = true
    @Published var isLoadingPurchase = false
    @Published var purchaseError: String?
    @Published var showRestoreSuccess = false
    @Published var premiumPrice: String = "$4.99"

    // MARK: - Dependencies
    private let premiumManager: PremiumManager
    private let userRepository: UserRepositoryProtocol
    private let appState: AppState
    private let purchaseService: PurchaseService

    var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    // MARK: - Initialization
    init(
        premiumManager: PremiumManager,
        userRepository: UserRepositoryProtocol,
        appState: AppState,
        purchaseService: PurchaseService? = nil
    ) {
        self.premiumManager = premiumManager
        self.userRepository = userRepository
        self.appState = appState
        self.purchaseService = purchaseService ?? PurchaseService()

        self.isPremium = appState.isPremiumUnlocked
    }

    // MARK: - Data Loading
    func loadData() async {
        isPremium = await premiumManager.checkPremiumStatus()

        if let prefs = await userRepository.getPreferences() {
            notificationsEnabled = prefs.notificationsEnabled
        }

        // Fetch dynamic price from StoreKit
        await purchaseService.loadProducts()
        if let product = purchaseService.premiumProduct {
            premiumPrice = product.displayPrice
        }
    }

    // MARK: - Actions
    func purchasePremium() async {
        isLoadingPurchase = true
        purchaseError = nil

        do {
            try await premiumManager.purchasePremium()
            isPremium = true
            appState.unlockPremium()
        } catch {
            purchaseError = error.localizedDescription
        }

        isLoadingPurchase = false
    }

    func restorePurchases() async {
        isLoadingPurchase = true
        purchaseError = nil

        do {
            try await premiumManager.restorePurchases()
            isPremium = premiumManager.isPremiumUnlocked
            if isPremium {
                appState.unlockPremium()
                showRestoreSuccess = true
            }
        } catch {
            purchaseError = error.localizedDescription
        }

        isLoadingPurchase = false
    }

    func updateNotificationPreference(_ enabled: Bool) {
        notificationsEnabled = enabled
        Task {
            await userRepository.updateNotificationPreference(enabled: enabled)
        }
    }

    func resetProgress() async {
        // This would clear all user data
        // Implementation depends on requirements
    }
}
