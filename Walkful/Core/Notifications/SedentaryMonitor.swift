import Foundation
import BackgroundTasks
import HealthKit
import UserNotifications

/// Detects sedentary periods on-device using a periodic background refresh task.
/// When iOS wakes the app, it checks recent step activity from HealthKit and, if
/// the user has been still during their active-hours window (and hasn't been
/// nudged recently), fires a gentle local notification. Entirely on-device.
///
/// Background firing is opportunistic — iOS decides when to run refresh tasks —
/// so this complements, rather than replaces, a light baseline schedule.
enum SedentaryMonitor {

    static let taskID = "com.iamjarl.walkful.sedentary-check"

    private static let store = HKHealthStore()
    private static let stepType = HKQuantityType(.stepCount)

    private static let kEnabled = "walkful.nudgesEnabled"
    private static let kStart = "walkful.nudgeStartHour"
    private static let kEnd = "walkful.nudgeEndHour"
    private static let kLastNudge = "walkful.lastSedentaryNudge"

    private static let stepThreshold = 250          // < this in the window = "still"
    private static let lookbackMinutes = 60
    private static let minHoursBetweenNudges = 2.0

    /// Mirror the settings the background task needs (it can't easily reach SwiftData).
    static func updateSettings(enabled: Bool, startHour: Int, endHour: Int) {
        let d = UserDefaults.standard
        d.set(enabled, forKey: kEnabled)
        d.set(startHour, forKey: kStart)
        d.set(endHour, forKey: kEnd)
    }

    /// Register the task handler. Must be called before the app finishes launching.
    static func register() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskID, using: nil) { task in
            guard let refresh = task as? BGAppRefreshTask else { task.setTaskCompleted(success: false); return }
            handle(refresh)
        }
    }

    /// Ask iOS to run the check again later (~2h out).
    static func schedule() {
        let request = BGAppRefreshTaskRequest(identifier: taskID)
        request.earliestBeginDate = Date(timeIntervalSinceNow: minHoursBetweenNudges * 60 * 60)
        try? BGTaskScheduler.shared.submit(request)
    }

    private static func handle(_ task: BGAppRefreshTask) {
        schedule() // always queue the next check first
        let work = Task {
            await evaluate()
            task.setTaskCompleted(success: true)
        }
        task.expirationHandler = { work.cancel() }
    }

    /// The core decision: are we sedentary, in-window, and due for a nudge?
    static func evaluate() async {
        let d = UserDefaults.standard
        guard d.bool(forKey: kEnabled) else { return }

        let hour = Calendar.current.component(.hour, from: Date())
        let start = d.integer(forKey: kStart)
        let end = d.integer(forKey: kEnd)
        guard hour >= start, hour < end else { return }

        if let last = d.object(forKey: kLastNudge) as? Date,
           Date().timeIntervalSince(last) < minHoursBetweenNudges * 60 * 60 {
            return
        }

        // nil = we couldn't read steps (e.g. Health access not granted/revoked).
        // Don't nudge in that case — a read failure isn't evidence of sitting still.
        guard let steps = await stepsInLast(minutes: lookbackMinutes) else { return }
        guard steps < stepThreshold else { return }

        await notifyMove()
        d.set(Date(), forKey: kLastNudge)
    }

    private static func stepsInLast(minutes: Int) async -> Int? {
        let start = Date(timeIntervalSinceNow: -Double(minutes) * 60)
        let predicate = HKQuery.predicateForSamples(withStart: start, end: Date())
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: stepType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, stats, error in
                // Distinguish a real error (→ nil, skip the nudge) from a genuine
                // zero-step window (stats present, no sum → 0, so the nudge fires).
                if error != nil {
                    continuation.resume(returning: nil)
                } else {
                    continuation.resume(returning: Int(stats?.sumQuantity()?.doubleValue(for: .count()) ?? 0))
                }
            }
            store.execute(query)
        }
    }

    private static func notifyMove() async {
        let content = UNMutableNotificationContent()
        content.title = "Time to move"
        content.body = "You've been still for a while — a short walk or the stairs?"
        content.sound = .default
        let request = UNNotificationRequest(
            identifier: "walkful.sedentary." + UUID().uuidString,
            content: content,
            trigger: nil // deliver now
        )
        try? await UNUserNotificationCenter.current().add(request)
    }
}
