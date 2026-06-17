import Foundation
import UserNotifications

/// Plans gentle, local movement reminders. No server.
///
/// Two layers:
/// 1. A light baseline of scheduled nudges, clamped to the user's active-hours window.
/// 2. `SedentaryMonitor` — the smart layer that fires only when you've actually been
///    still (checked from HealthKit in the background).
enum NudgeScheduler {

    private static let center = UNUserNotificationCenter.current()
    private static let idPrefix = "walkful.nudge."

    private static let nudges: [(hour: Int, title: String, body: String)] = [
        (11, "Time to move", "A short walk now keeps the day from sitting still."),
        (15, "Stretch your legs", "Take the stairs or a quick lap — every step counts."),
        (19, "Evening steps", "A gentle walk now tops up your day.")
    ]

    static func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    /// Syncs scheduled nudges + the sedentary monitor with the user's settings. Idempotent.
    static func reschedule(enabled: Bool, startHour: Int, endHour: Int) async {
        // Keep the background monitor's mirrored settings in sync, and (re)queue it.
        SedentaryMonitor.updateSettings(enabled: enabled, startHour: startHour, endHour: endHour)

        center.removeAllPendingNotificationRequests()
        guard enabled else { return }
        guard await requestAuthorization() else { return }

        SedentaryMonitor.schedule()

        // Baseline scheduled nudges, only within the active-hours window.
        for (index, nudge) in nudges.enumerated() where nudge.hour >= startHour && nudge.hour < endHour {
            let content = UNMutableNotificationContent()
            content.title = nudge.title
            content.body = nudge.body
            content.sound = .default

            var when = DateComponents()
            when.hour = nudge.hour
            when.minute = 0
            let trigger = UNCalendarNotificationTrigger(dateMatching: when, repeats: true)

            let request = UNNotificationRequest(
                identifier: idPrefix + "\(index)",
                content: content,
                trigger: trigger
            )
            try? await center.add(request)
        }
    }
}
