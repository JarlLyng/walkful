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
    private(set) var isLoadingProduct = false
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
        await loadProduct()
    }

    /// Fetch the Pro product. Safe to call again, which is the point: a load that
    /// failed at launch (offline, or the product not yet approved for sale) used
    /// to stay failed for the whole session.
    @discardableResult
    func loadProduct() async -> Bool {
        guard !isLoadingProduct else { return proProduct != nil }
        isLoadingProduct = true
        defer { isLoadingProduct = false }
        do {
            proProduct = try await Product.products(for: [Self.proID]).first
        } catch {
            proProduct = nil
        }
        return proProduct != nil
    }

    /// False when the App Store never handed us the product, in which case the
    /// paywall must not present a buy button it cannot honour.
    var isProductAvailable: Bool { proProduct != nil }

    var displayPrice: String { proProduct?.displayPrice ?? "" }

    func purchase() async {
        guard !isPurchasing else { return }
        isPurchasing = true
        purchaseError = nil
        defer { isPurchasing = false }

        // The product can still be missing here if the launch-time load failed.
        // Retry once, then say so out loud. Returning silently is what made a
        // broken paywall look exactly like an unpopular one (#134).
        if proProduct == nil { await loadProduct() }
        guard let proProduct else {
            purchaseError = String(localized: "Walkful Pro isn't available from the App Store right now. Please check your connection and try again.")
            return
        }

        do {
            let result = try await proProduct.purchase()
            switch result {
            case .success(.verified(let transaction)):
                await transaction.finish()
                await refreshEntitlement()
            case .success(.unverified):
                purchaseError = String(localized: "We couldn't verify that purchase. If you were charged, tap Restore purchase.")
            case .pending:
                purchaseError = String(localized: "Your purchase is waiting for approval (e.g. Ask to Buy). Walkful Pro unlocks once it's approved.")
            case .userCancelled:
                break // no message — the user chose to cancel
            @unknown default:
                break
            }
        } catch {
            purchaseError = String(localized: "Something went wrong with the purchase. Please try again.")
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
