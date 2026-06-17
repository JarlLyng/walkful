import Foundation

// Walkful er en engelsk/international app. Vi grupperer tal med komma
// (en_US) indtil vi evt. tilbyder fuld locale-tilpasning senere.
private let enUS = Locale(identifier: "en_US")

extension Int {
    var stepsFormatted: String {
        self.formatted(.number.grouping(.automatic).locale(enUS))
    }
}
