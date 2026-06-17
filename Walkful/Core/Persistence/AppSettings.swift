import Foundation
import SwiftData

/// Brugerens indstillinger — gemt on-device med SwiftData.
/// Vi behandler den som en singleton (én række).
@Model
final class AppSettings {
    var dailyGoal: Int
    var nudgesEnabled: Bool
    var hasOnboarded: Bool

    /// Aktiv-tidsvindue for nudges (quiet hours uden for). 24-timers ur.
    var nudgeStartHour: Int
    var nudgeEndHour: Int

    init(dailyGoal: Int = 7_000,
         nudgesEnabled: Bool = true,
         hasOnboarded: Bool = false,
         nudgeStartHour: Int = 9,
         nudgeEndHour: Int = 21) {
        self.dailyGoal = dailyGoal
        self.nudgesEnabled = nudgesEnabled
        self.hasOnboarded = hasOnboarded
        self.nudgeStartHour = nudgeStartHour
        self.nudgeEndHour = nudgeEndHour
    }
}
