import Foundation
import UserNotifications

/// Plans gentle, local movement reminders. No server.
///
/// One layer only: `SedentaryMonitor` — nudges fire when you've actually been
/// still (checked from HealthKit in the background), never on a fixed clock.
/// An earlier baseline of scheduled clock nudges was removed (#113): iOS
/// delivered those blindly, so they could tell someone with 13,000 steps to
/// "get moving", contradicting the smart-nudge promise in the app and FAQ.
enum NudgeScheduler {

    private static let center = UNUserNotificationCenter.current()

    static func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    /// Syncs the sedentary monitor with the user's settings. Idempotent.
    /// Also clears any pending scheduled nudges left behind by pre-1.0.4
    /// versions (the removed clock-based baseline used repeating triggers,
    /// which survive app updates until explicitly removed).
    ///
    /// Clears everything except an interval walk's cues. It used to remove
    /// every pending request, which would have silenced a walk in progress
    /// whenever nudge settings changed (#174). Filtering by the coach's prefix
    /// rather than listing nudge identifiers keeps the legacy cleanup intact,
    /// whatever identifiers those old requests used.
    static func reschedule(enabled: Bool, startHour: Int, endHour: Int) async {
        if LaunchArgs.screenshots { return } // no permission prompts during screenshots
        SedentaryMonitor.updateSettings(enabled: enabled, startHour: startHour, endHour: endHour)

        let pending = await center.pendingNotificationRequests().map(\.identifier)
        center.removePendingNotificationRequests(
            withIdentifiers: CoachCues.identifiersNotOwnedByCoach(pending))
        guard enabled else { return }
        guard await requestAuthorization() else { return }

        SedentaryMonitor.schedule()
    }
}
