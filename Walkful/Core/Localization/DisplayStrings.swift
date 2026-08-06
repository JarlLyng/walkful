import Foundation

/// Localized display forms for values the app models as cases rather than
/// strings. Keeping these out of `HealthKitService` leaves the service free of
/// presentation concerns, and keeping a whole sentence per case (rather than
/// injecting a translated noun into a fixed sentence) is what makes the Danish
/// read like Danish instead of translated English.
extension HealthKitService.TimeOfDay {

    /// Short form for a stat chip.
    var label: LocalizedStringResource {
        switch self {
        case .night: "Late night"
        case .morning: "Mornings"
        case .afternoon: "Afternoons"
        case .evening: "Evenings"
        }
    }

    /// Full sentence for the Insights action card. One per case on purpose: the
    /// preposition and article differ per part of day in Danish, so there is no
    /// single template that both languages can fill in.
    var insightMessage: LocalizedStringResource {
        switch self {
        case .night:
            "You move most late at night. Planning a walk then makes it easier to hit your goal."
        case .morning:
            "You move most in the mornings. Planning a walk then makes it easier to hit your goal."
        case .afternoon:
            "You move most in the afternoons. Planning a walk then makes it easier to hit your goal."
        case .evening:
            "You move most in the evenings. Planning a walk then makes it easier to hit your goal."
        }
    }
}
