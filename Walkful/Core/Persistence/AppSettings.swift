import Foundation
import SwiftData

/// Brugerens indstillinger — gemt on-device med SwiftData.
/// Vi behandler den som en singleton (én række).
@Model
final class AppSettings {
    // NB: inline default values are REQUIRED for SwiftData lightweight migration.
    // A default only in init() is not enough — adding a non-optional property
    // without an inline default fails to open an existing store (white screen on
    // upgrade). Keep an inline default on every property.
    var dailyGoal: Int = 7_000
    var nudgesEnabled: Bool = true
    var hasOnboarded: Bool = false

    /// Aktiv-tidsvindue for nudges (quiet hours uden for). 24-timers ur.
    var nudgeStartHour: Int = 9
    var nudgeEndHour: Int = 21

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
