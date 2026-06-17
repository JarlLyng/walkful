import Foundation

/// A tiny snapshot of today's progress, shared with the widget via an App Group.
/// The app writes it; the widget reads it. Stays entirely on-device.
struct DailySnapshot: Codable {
    let steps: Int
    let goal: Int
    let date: Date

    var progress: Double { goal > 0 ? min(Double(steps) / Double(goal), 1) : 0 }
}

enum SharedStore {
    static let appGroupID = "group.com.iamjarl.walkful"
    private static let key = "today.snapshot"

    static func save(steps: Int, goal: Int) {
        let snapshot = DailySnapshot(steps: steps, goal: goal, date: Date())
        guard let defaults = UserDefaults(suiteName: appGroupID),
              let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults.set(data, forKey: key)
    }

    static func load() -> DailySnapshot? {
        guard let defaults = UserDefaults(suiteName: appGroupID),
              let data = defaults.data(forKey: key),
              let snapshot = try? JSONDecoder().decode(DailySnapshot.self, from: data) else { return nil }
        return snapshot
    }
}
