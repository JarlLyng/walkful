import Foundation
import SwiftData

/// The user's settings, stored on the device with SwiftData.
/// Treated as a singleton: there is exactly one row (RootContainer makes it).
@Model
final class AppSettings {
    // NB: inline default values are REQUIRED for SwiftData lightweight migration.
    // A default only in init() is not enough — adding a non-optional property
    // without an inline default fails to open an existing store (white screen on
    // upgrade). Keep an inline default on every property.
    var dailyGoal: Int = 7_000
    var nudgesEnabled: Bool = true
    var hasOnboarded: Bool = false

    /// The active-hours window for nudges, on a 24-hour clock. A nudge can fire
    /// when `nudgeStartHour <= hour < nudgeEndHour`, so the end hour itself is
    /// already quiet, and every hour outside the window is quiet too.
    var nudgeStartHour: Int = 9
    var nudgeEndHour: Int = 21

    /// Show distance in miles instead of kilometres.
    var useImperial: Bool = false

    /// Let the daily goal rise in steps as the recent average grows. It never falls.
    var adaptiveGoal: Bool = false

    /// The day the goal was last celebrated, so the success haptic fires once a
    /// day, not on every launch.
    var lastGoalCelebrationDay: Date = Date.distantPast

    /// The App Store review prompt is asked for once ever, at a good moment.
    var hasRequestedReview: Bool = false

    /// The day the goal last changed, by hand or adaptively. It limits the
    /// adaptive goal to one change a day, and keeps it from overriding a goal
    /// the user set by hand that same day.
    var lastGoalAdjustmentDay: Date = Date.distantPast

    init(dailyGoal: Int = 7_000,
         nudgesEnabled: Bool = true,
         hasOnboarded: Bool = false,
         nudgeStartHour: Int = 9,
         nudgeEndHour: Int = 21,
         useImperial: Bool = false,
         adaptiveGoal: Bool = false,
         lastGoalCelebrationDay: Date = .distantPast,
         hasRequestedReview: Bool = false,
         lastGoalAdjustmentDay: Date = .distantPast) {
        self.dailyGoal = dailyGoal
        self.nudgesEnabled = nudgesEnabled
        self.hasOnboarded = hasOnboarded
        self.nudgeStartHour = nudgeStartHour
        self.nudgeEndHour = nudgeEndHour
        self.useImperial = useImperial
        self.adaptiveGoal = adaptiveGoal
        self.lastGoalCelebrationDay = lastGoalCelebrationDay
        self.hasRequestedReview = hasRequestedReview
        self.lastGoalAdjustmentDay = lastGoalAdjustmentDay
    }
}
