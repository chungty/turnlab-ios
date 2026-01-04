import Foundation
import StoreKit

/// StoreKit 2 service for in-app purchases.
@MainActor
final class PurchaseService: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs: Set<String> = []
    @Published private(set) var isLoading = false

    private var updateListenerTask: Task<Void, Error>?

    init() {
        // Start listening for transaction updates
        updateListenerTask = listenForTransactions()

        // Load products
        Task {
            await loadProducts()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Products

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            products = try await Product.products(for: [ProductIdentifiers.premium])
        } catch {
            print("Failed to load products: \(error)")
        }
    }

    var premiumProduct: Product? {
        products.first { $0.id == ProductIdentifiers.premium }
    }

    // MARK: - Purchase Status

    func isPremiumPurchased() async -> Bool {
        await updatePurchasedProducts()
        return purchasedProductIDs.contains(ProductIdentifiers.premium)
    }

    private func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                purchasedProductIDs.insert(transaction.productID)
            }
        }
    }

    // MARK: - Purchase

    func purchase() async throws {
        guard let product = premiumProduct else {
            throw PurchaseError.productNotFound
        }

        isLoading = true
        defer { isLoading = false }

        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            purchasedProductIDs.insert(transaction.productID)
            await transaction.finish()

        case .userCancelled:
            throw PurchaseError.cancelled

        case .pending:
            throw PurchaseError.pending

        @unknown default:
            throw PurchaseError.unknown
        }
    }

    // MARK: - Restore

    func restore() async throws {
        isLoading = true
        defer { isLoading = false }

        try await AppStore.sync()
        await updatePurchasedProducts()
    }

    // MARK: - Transaction Listener

    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)
                    await MainActor.run {
                        self.purchasedProductIDs.insert(transaction.productID)
                    }
                    await transaction.finish()
                } catch {
                    print("Transaction failed verification: \(error)")
                }
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw PurchaseError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }
}

// MARK: - Errors
enum PurchaseError: LocalizedError {
    case productNotFound
    case cancelled
    case pending
    case verificationFailed
    case unknown

    var errorDescription: String? {
        switch self {
        case .productNotFound: return "Product not found"
        case .cancelled: return "Purchase was cancelled"
        case .pending: return "Purchase is pending approval"
        case .verificationFailed: return "Purchase verification failed"
        case .unknown: return "An unknown error occurred"
        }
    }
}
