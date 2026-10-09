import Foundation

extension Int {
    /// Step counts grouped for the reader's locale (1,234 in English,
    /// 1.234 in Danish). This was pinned to en_US while the UI was
    /// English-only; now that the app is localized it has to follow the
    /// language, or a Danish screen would show English grouping.
    var stepsFormatted: String {
        self.formatted(.number.grouping(.automatic))
    }
}

extension Double {
    /// One decimal for the reader's locale: 5.8 in English, 5,8 in Danish
    /// (#195). `String(format: "%.1f")` always writes a full stop whatever
    /// the language, so it must not format anything a reader sees.
    func oneDecimal(locale: Locale = .current) -> String {
        self.formatted(.number.precision(.fractionLength(1)).locale(locale))
    }
}

/// Afstandsvisning — HealthKit giver os kilometer; vi konverterer til
/// brugerens valgte enhed (metrisk/imperial).
enum Units {
    static let kmPerMile = 1.609344

    static func distance(km: Double, imperial: Bool) -> Double {
        imperial ? km / kmPerMile : km
    }

    /// The unit symbols are identical in both languages, so these stay literal.
    static func label(imperial: Bool) -> String {
        imperial ? "mi" : "km"
    }
}
