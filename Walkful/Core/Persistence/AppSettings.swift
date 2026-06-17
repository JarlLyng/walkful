import Foundation
import SwiftData

/// Brugerens indstillinger — gemt on-device med SwiftData.
/// Vi behandler den som en singleton (én række).
@Model
final class AppSettings {
    var dailyGoal: Int
    var nudgesEnabled: Bool
    var hasOnboarded: Bool

    init(dailyGoal: Int = 7_000, nudgesEnabled: Bool = true, hasOnboarded: Bool = false) {
        self.dailyGoal = dailyGoal
        self.nudgesEnabled = nudgesEnabled
        self.hasOnboarded = hasOnboarded
    }
}
