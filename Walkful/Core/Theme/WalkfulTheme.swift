import SwiftUI
import UIKit
import IAMJARLDesignTokens

// MARK: - IAMJARL design tokens
//
// `Tokens` er en tynd facade oven på IAMJARL-pakken (IAMJARLDesignTokens).
// Resten af appen bruger kun `Tokens.*`, så design-systemet kan udvikle sig
// uden at vi rører views. Pakken giver separate Light/Dark-farver; vi pakker
// dem i light/dark-adaptive SwiftUI-Colors her.
//
// Regel fra IAMJARL: brug KUN disse tokens i views — ingen hardcodede værdier.

enum Tokens {

    enum Palette {
        // Brand
        static let primary   = adaptive(L.primary, D.primary)
        static let onPrimary = Color(light: 0xFFFFFF, dark: 0x000000) // hvid på lilla / sort på lime
        static let accentText = adaptive(L.primary, D.primary)

        // Baggrund & tekst
        static let appBackground = adaptive(L.Background.app, D.Background.app)
        static let textPrimary   = adaptive(L.Text.primary, D.Text.primary)
        static let textSecondary = adaptive(L.Text.secondary, D.Text.secondary)
        static let textTertiary  = adaptive(L.Text.tertiary, D.Text.tertiary)

        // Flader & kanter
        static let mutedFill     = adaptive(L.Background.muted, D.Background.muted)
        static let borderSubtle  = adaptive(L.Border.subtle, D.Border.subtle)
        static let borderDefault = adaptive(L.Border.default, D.Border.default)
        // Ring-track er en afledt UI-værdi (ikke et brand-token)
        static let ringTrack = Color(lightWhite: 0, lightAlpha: 0.08,
                                     darkWhite: 1, darkAlpha: 0.12)

        // States
        static let success = adaptive(L.State.success, D.State.success)
        static let warning = adaptive(L.State.warning, D.State.warning)
        static let error   = adaptive(L.State.error, D.State.error)

        // Genveje til pakkens light/dark-namespaces
        private typealias L = DesignTokens.ColorToken.Light
        private typealias D = DesignTokens.ColorToken.Dark
    }

    enum Spacing {
        static let xs = DesignTokens.Spacing.xs
        static let sm = DesignTokens.Spacing.sm
        static let md = DesignTokens.Spacing.md
        static let lg = DesignTokens.Spacing.lg
        static let xl = DesignTokens.Spacing.xl
        static let xxl = DesignTokens.Spacing.xxl
        static let xxxl = DesignTokens.Spacing.xxxl
    }

    enum Radius {
        static let sm = DesignTokens.Radius.sm
        static let md = DesignTokens.Radius.md
        static let lg = DesignTokens.Radius.lg
    }

    enum FontSize {
        static let xs = DesignTokens.Typography.Size.xs
        static let sm = DesignTokens.Typography.Size.sm
        static let base = DesignTokens.Typography.Size.base
        static let lg = DesignTokens.Typography.Size.lg
        static let xl = DesignTokens.Typography.Size.xl
        static let xxl = DesignTokens.Typography.Size.xxl
    }

    /// Rounded numerals for the "premium" feel (Aurora).
    static func rounded(_ size: CGFloat, _ weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }

    /// Scalable text styles (Dynamic Type). Prefer these over fixed sizes so
    /// text grows with the user's Larger Text setting.
    enum TextStyle {
        static let hero = Font.system(.largeTitle, design: .rounded).weight(.bold)
        static let bigTitle = Font.system(.largeTitle).weight(.semibold)
        static let titleNumber = Font.system(.title2, design: .rounded).weight(.semibold)
        static let statNumber = Font.system(.title3, design: .rounded).weight(.semibold)
        static let title = Font.system(.title3).weight(.semibold)
        static let headline = Font.system(.headline)
        static let body = Font.system(.body)
        static let subheadlineSemibold = Font.system(.subheadline).weight(.semibold)
        static let subheadline = Font.system(.subheadline)
        static let caption = Font.system(.caption)
    }

    // MARK: - Aurora — derived gradient/glow layer (built from the brand colors)

    enum Gradient {
        /// Ring + hero accent. Light: purple→pink · Dark: lime→teal→blue.
        static let ring = LinearGradient(
            colors: [
                Color(light: 0xA435D2, dark: 0xD0FF00),
                Color(light: 0xE0529C, dark: 0x5DE0A6),
                Color(light: 0xE0529C, dark: 0x37B6E9)
            ],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
        /// Vertical fill for bars.
        static let bars = LinearGradient(
            colors: [
                Color(light: 0xA435D2, dark: 0xD0FF00),
                Color(light: 0xE0529C, dark: 0x37B6E9)
            ],
            startPoint: .top, endPoint: .bottom
        )
        /// Subtle aurora screen backdrop.
        static let heroBackdrop = LinearGradient(
            colors: [
                Color(light: 0xFBF6FF, dark: 0x15101F),
                Color(light: 0xFFFFFF, dark: 0x000000)
            ],
            startPoint: .top, endPoint: .bottom
        )
    }
}

// MARK: - Color helpers (light/dark-aware)

/// Bygger en adaptiv SwiftUI-Color ud fra pakkens separate light/dark-farver.
private func adaptive(_ light: Color, _ dark: Color) -> Color {
    Color(UIColor { trait in
        UIColor(trait.userInterfaceStyle == .dark ? dark : light)
    })
}

extension Color {
    /// Opaque farve fra 0xRRGGBB, forskellig i light og dark.
    init(light: UInt, dark: UInt) {
        self.init(UIColor { trait in
            UIColor(rgb: trait.userInterfaceStyle == .dark ? dark : light)
        })
    }

    /// Hvid/sort med alpha, forskellig i light og dark.
    init(lightWhite: CGFloat, lightAlpha: CGFloat,
         darkWhite: CGFloat, darkAlpha: CGFloat) {
        self.init(UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(white: darkWhite, alpha: darkAlpha)
                : UIColor(white: lightWhite, alpha: lightAlpha)
        })
    }
}

extension UIColor {
    convenience init(rgb: UInt) {
        self.init(
            red: CGFloat((rgb >> 16) & 0xFF) / 255,
            green: CGFloat((rgb >> 8) & 0xFF) / 255,
            blue: CGFloat(rgb & 0xFF) / 255,
            alpha: 1
        )
    }
}
