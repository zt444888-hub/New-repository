import Foundation
import StoreKit

public enum StoreError: LocalizedError {
    case notFound, pending, unknown
    public var errorDescription: String? {
        switch self {
        case .notFound: return "Product not found"
        case .pending: return "Purchase pending"
        case .unknown: return "Unknown error"
        }
    }
}

@available(iOS 15.0, *)
@MainActor
public final class StoreManager: ObservableObject {
    public static let shared = StoreManager()
    public static let productID = "com.mediamate.full"

    @Published public private(set) var isPurchased = false
    @Published public private(set) var isLoading = false
    @Published public private(set) var product: Product?

    private var updatesTask: Task<Void, Never>?

    private init() {
        updatesTask = listenForTransactions()
        Task { await loadProduct() }
    }

    deinit {
        updatesTask?.cancel()
    }

    public func loadProduct() async {
        isLoading = true
        defer { isLoading = false }
        do {
            let products = try await Product.products(for: [Self.productID])
            product = products.first
            // Check if already purchased
            if let entitlement = await Transaction.currentEntitlement(for: Self.productID) {
                if case .verified = entitlement {
                    isPurchased = true
                }
            }
        } catch {
            print("StoreManager: Failed to load product: \(error)")
        }
    }

    public func purchase() async throws {
        guard let product = product else { throw StoreError.notFound }
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            if case .verified(let transaction) = verification {
                await transaction.finish()
                isPurchased = true
            }
        case .userCancelled:
            throw StoreError.pending
        case .pending:
            throw StoreError.pending
        @unknown default:
            throw StoreError.unknown
        }
    }

    public func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await AppStore.sync()
            if let entitlement = await Transaction.currentEntitlement(for: Self.productID) {
                if case .verified = entitlement {
                    isPurchased = true
                }
            }
        } catch {
            print("StoreManager: Restore failed: \(error)")
        }
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await MainActor.run { self?.isPurchased = true }
                }
            }
        }
    }
}
