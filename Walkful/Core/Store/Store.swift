import Foundation
import StoreKit
import Observation

/// One-time "Walkful Pro" unlock (Insights + interval coach). StoreKit 2,
/// on-device entitlement check — no server, no subscription.
@MainActor
@Observable
final class Store {

    static let proID = "com.iamjarl.walkful.pro"

    private(set) var proProduct: Product?
    private(set) var isPro = false
    private(set) var isPurchasing = false
    /// User-facing message when a purchase fails or is pending; nil when clear.
    private(set) var purchaseError: String?

    func clearPurchaseError() { purchaseError = nil }

    private var updatesListener: Task<Void, Never>?

    init() {
        updatesListener = listenForTransactions()
    }

    /// Load the product and refresh the current entitlement.
    func load() async {
        await refreshEntitlement()
        do {
            let products = try await Product.products(for: [Self.proID])
            proProduct = products.first
        } catch {
            // Offline / not configured — stay in free tier silently.
        }
    }

    var displayPrice: String { proProduct?.displayPrice ?? "" }

    func purchase() async {
        guard let proProduct, !isPurchasing else { return }
        isPurchasing = true
        purchaseError = nil
        defer { isPurchasing = false }
        do {
            let result = try await proProduct.purchase()
            switch result {
            case .success(.verified(let transaction)):
                await transaction.finish()
                await refreshEntitlement()
            case .success(.unverified):
                purchaseError = "We couldn't verify that purchase. If you were charged, tap Restore purchase."
            case .pending:
                purchaseError = "Your purchase is waiting for approval (e.g. Ask to Buy). Walkful Pro unlocks once it's approved."
            case .userCancelled:
                break // no message — the user chose to cancel
            @unknown default:
                break
            }
        } catch {
            purchaseError = "Something went wrong with the purchase. Please try again."
        }
    }

    func restore() async {
        try? await AppStore.sync()
        await refreshEntitlement()
    }

    private func refreshEntitlement() async {
        var owned = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == Self.proID,
               transaction.revocationDate == nil {
                owned = true
            }
        }
        isPro = owned
    }

    #if DEBUG
    /// For App Store screenshots — unlock Pro without a purchase.
    func forcePro() { isPro = true }
    #endif

    private func listenForTransactions() -> Task<Void, Never> {
        Task { [weak self] in
            for await _ in Transaction.updates {
                await self?.refreshEntitlement()
            }
        }
    }
}
