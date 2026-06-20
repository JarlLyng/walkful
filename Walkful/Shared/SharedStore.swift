import Foundation

/// A tiny snapshot of today's progress, shared with the widget via an App Group.
/// The app writes it; the widget reads it. Stays entirely on-device.
struct DailySnapshot: Codable {
    let steps: Int
    let goal: Int
    let date: Date
    /// Step totals for the last 7 days, oldest→newest (most recent = today).
    let week: [Int]

    var progress: Double { goal > 0 ? min(Double(steps) / Double(goal), 1) : 0 }

    init(steps: Int, goal: Int, date: Date, week: [Int] = []) {
        self.steps = steps
        self.goal = goal
        self.date = date
        self.week = week
    }

    // Tolerant decode: snapshots written by older builds have no `week` key.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        steps = try c.decode(Int.self, forKey: .steps)
        goal = try c.decode(Int.self, forKey: .goal)
        date = try c.decode(Date.self, forKey: .date)
        week = (try? c.decode([Int].self, forKey: .week)) ?? []
    }
}

enum SharedStore {
    static let appGroupID = "group.com.iamjarl.walkful"
    private static let key = "today.snapshot"

    static func save(steps: Int, goal: Int, week: [Int] = []) {
        let snapshot = DailySnapshot(steps: steps, goal: goal, date: Date(), week: week)
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
