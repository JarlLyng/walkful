import Foundation

// Walkful er en engelsk/international app. Vi grupperer tal med komma
// (en_US) indtil vi evt. tilbyder fuld locale-tilpasning senere.
private let enUS = Locale(identifier: "en_US")

extension Int {
    var stepsFormatted: String {
        self.formatted(.number.grouping(.automatic).locale(enUS))
    }
}

/// Afstandsvisning — HealthKit giver os kilometer; vi konverterer til
/// brugerens valgte enhed (metrisk/imperial).
enum Units {
    static let kmPerMile = 1.609344

    static func distance(km: Double, imperial: Bool) -> Double {
        imperial ? km / kmPerMile : km
    }

    static func label(imperial: Bool) -> String {
        imperial ? "mi" : "km"
    }
}
