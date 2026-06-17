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
        defer { isPurchasing = false }
        do {
            let result = try await proProduct.purchase()
            if case .success(let verification) = result,
               case .verified(let transaction) = verification {
                await transaction.finish()
                await refreshEntitlement()
            }
        } catch {
            // Cancelled or failed — no state change.
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

    private func listenForTransactions() -> Task<Void, Never> {
        Task { [weak self] in
            for await _ in Transaction.updates {
                await self?.refreshEntitlement()
            }
        }
    }
}
