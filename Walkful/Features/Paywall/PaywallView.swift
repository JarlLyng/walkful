import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    var store: Store

    private let benefits: [(icon: String, title: String, body: String)] = [
        ("chart.bar.fill", "Insights", "Consistency heatmap, best time of day, brisk-minute trends and your lifetime distance."),
        ("figure.walk.motion", "Interval-walking coach", "Guided easy/brisk sessions with haptics — the evidence-based way to boost fitness."),
        ("lock.shield.fill", "Still 100% private", "One payment. No subscription, no ads, nothing leaves your device.")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.xl) {
            Spacer().frame(height: Tokens.Spacing.sm)
            Text("Walkful Pro")
                .font(Tokens.TextStyle.bigTitle)
                .foregroundStyle(Tokens.Palette.textPrimary)
            Text("Unlock the parts that help you move more — once, forever.")
                .font(Tokens.TextStyle.body)
                .foregroundStyle(Tokens.Palette.textSecondary)

            VStack(alignment: .leading, spacing: Tokens.Spacing.lg) {
                ForEach(benefits, id: \.title) { b in
                    HStack(alignment: .top, spacing: Tokens.Spacing.md) {
                        Image(systemName: b.icon)
                            .font(.system(size: 22))
                            .foregroundStyle(Tokens.Palette.primary)
                            .frame(width: 28)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(b.title)
                                .font(Tokens.TextStyle.headline)
                                .foregroundStyle(Tokens.Palette.textPrimary)
                            Text(b.body)
                                .font(Tokens.TextStyle.subheadline)
                                .foregroundStyle(Tokens.Palette.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }

            Spacer()

            PrimaryButton(title: store.displayPrice.isEmpty ? "Unlock Walkful Pro" : "Unlock Pro · \(store.displayPrice)") {
                Task {
                    await store.purchase()
                    if store.isPro { dismiss() }
                }
            }
            .opacity(store.isPurchasing ? 0.6 : 1)
            .disabled(store.isPurchasing)

            HStack {
                Button("Restore purchase") { Task { await store.restore(); if store.isPro { dismiss() } } }
                Spacer()
                Button("Not now") { dismiss() }
            }
            .font(Tokens.TextStyle.subheadline)
            .foregroundStyle(Tokens.Palette.textSecondary)
        }
        .padding(Tokens.Spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Tokens.Palette.appBackground)
        .alert("Purchase", isPresented: Binding(
            get: { store.purchaseError != nil },
            set: { if !$0 { store.clearPurchaseError() } }
        ), presenting: store.purchaseError) { _ in
            Button("OK", role: .cancel) { }
        } message: { Text($0) }
    }
}
