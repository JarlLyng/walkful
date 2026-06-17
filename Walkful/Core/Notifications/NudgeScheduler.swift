import Foundation
import UserNotifications

/// Planlægger venlige, lokale bevægelses-påmindelser. Ingen server.
/// Robust første version: faste tidspunkter på dagen. Næste lag bliver
/// HealthKit-drevet "du har siddet stille"-detektion.
enum NudgeScheduler {

    private static let center = UNUserNotificationCenter.current()
    private static let idPrefix = "walkful.nudge."

    private static let nudges: [(hour: Int, title: String, body: String)] = [
        (11, "Time to move", "A short walk now keeps the day from sitting still."),
        (15, "Stretch your legs", "Take the stairs or a quick lap — every step counts."),
        (19, "Evening steps", "A gentle walk now tops up your day.")
    ]

    /// Beder om tilladelse til notifikationer. Returnerer om det blev givet.
    static func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    /// Synkroniserer planlagte nudges med brugerens valg. Idempotent.
    static func reschedule(enabled: Bool) async {
        center.removeAllPendingNotificationRequests()
        guard enabled else { return }
        guard await requestAuthorization() else { return }

        for (index, nudge) in nudges.enumerated() {
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
