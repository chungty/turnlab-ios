import Foundation
import StoreKit
import os.log

private let logger = Logger(subsystem: "com.turnlab.app", category: "PurchaseService")

/// StoreKit 2 service for in-app purchases.
@MainActor
final class PurchaseService: ObservableObject {
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs: Set<String> = []
    @Published private(set) var isLoading = false
    @Published private(set) var lastLoadError: Error?

    private var updateListenerTask: Task<Void, Error>?
    private var isInitialized = false
    private var initializationTask: Task<Void, Never>?

    /// Maximum number of retry attempts for loading products
    private let maxRetryAttempts = 5
    /// Base delay between retries (doubles each attempt)
    private let baseRetryDelay: UInt64 = 2_000_000_000 // 2 seconds in nanoseconds

    init() {
        logger.info("PurchaseService initializing...")

        // Start listening for transaction updates
        updateListenerTask = listenForTransactions()

        // Load products with retry
        initializationTask = Task {
            await loadProductsWithRetry()
            isInitialized = true
            logger.info("PurchaseService initialization complete. Products loaded: \(self.products.count)")
        }
    }

    /// Waits for the initial product loading to complete
    func waitForInitialization() async {
        await initializationTask?.value
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Products

    /// Loads products with automatic retry on failure
    func loadProductsWithRetry() async {
        for attempt in 1...maxRetryAttempts {
            logger.info("Loading products (attempt \(attempt)/\(self.maxRetryAttempts))")

            do {
                try await loadProducts()
                if !products.isEmpty {
                    logger.info("Successfully loaded \(self.products.count) product(s)")
                    lastLoadError = nil
                    return
                } else {
                    logger.warning("Product request succeeded but returned empty array")
                }
            } catch {
                logger.error("Failed to load products (attempt \(attempt)): \(error.localizedDescription)")
                lastLoadError = error
            }

            // Wait before retry with exponential backoff
            if attempt < maxRetryAttempts {
                let delay = baseRetryDelay * UInt64(1 << (attempt - 1))
                logger.info("Waiting \(Double(delay) / 1_000_000_000)s before retry...")
                try? await Task.sleep(nanoseconds: delay)
            }
        }

        logger.error("Failed to load products after \(self.maxRetryAttempts) attempts")
    }

    /// Core product loading - throws on error
    private func loadProducts() async throws {
        isLoading = true
        defer { isLoading = false }

        let productIDs = [ProductIdentifiers.premium]
        logger.debug("Requesting products: \(productIDs)")

        products = try await Product.products(for: productIDs)

        logger.debug("Received \(self.products.count) products")
        for product in products {
            logger.debug("  - \(product.id): \(product.displayName) @ \(product.displayPrice)")
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
        logger.info("Purchase requested")

        // Wait for any ongoing initialization to complete
        if !isInitialized {
            logger.info("Waiting for initialization to complete...")
            await waitForInitialization()
        }

        // If still no products, try loading again with longer timeout
        if products.isEmpty {
            logger.warning("Products not loaded after init, attempting to load again...")
            await loadProductsWithRetry()

            // Final attempt with even longer delay for sandbox
            if products.isEmpty {
                logger.warning("Still no products, waiting 5s and trying one more time...")
                try? await Task.sleep(nanoseconds: 5_000_000_000)
                await loadProductsWithRetry()
            }
        }

        guard let product = premiumProduct else {
            let availableIds = self.products.map { $0.id }
            logger.error("Premium product not available after loading. Product ID: \(ProductIdentifiers.premium)")
            logger.error("Available products: \(availableIds)")
            if let error = lastLoadError {
                logger.error("Last load error: \(error.localizedDescription)")
            }
            throw PurchaseError.productNotFoundWithDetails(
                requestedId: ProductIdentifiers.premium,
                availableIds: availableIds
            )
        }

        logger.info("Starting purchase for: \(product.id)")
        isLoading = true
        defer { isLoading = false }

        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            purchasedProductIDs.insert(transaction.productID)
            await transaction.finish()
            logger.info("Purchase successful: \(transaction.productID)")

        case .userCancelled:
            logger.info("Purchase cancelled by user")
            throw PurchaseError.cancelled

        case .pending:
            logger.info("Purchase pending approval")
            throw PurchaseError.pending

        @unknown default:
            logger.error("Unknown purchase result")
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
                    _ = await MainActor.run {
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
    case productNotFoundWithDetails(requestedId: String, availableIds: [String])
    case cancelled
    case pending
    case verificationFailed
    case unknown

    var errorDescription: String? {
        switch self {
        case .productNotFound:
            return "Product not found. Please check your internet connection and try again."
        case .productNotFoundWithDetails(let requestedId, let availableIds):
            if availableIds.isEmpty {
                return "Unable to load products from App Store. Requested: \(requestedId). Please check your connection and try again."
            } else {
                return "Product '\(requestedId)' not found. Available: \(availableIds.joined(separator: ", "))"
            }
        case .cancelled:
            return "Purchase was cancelled"
        case .pending:
            return "Purchase is pending approval"
        case .verificationFailed:
            return "Purchase verification failed"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}
