import XCTest
@testable import Walkful

final class DailySnapshotTests: XCTestCase {

    private let cal = Calendar.current

    func testIsFromTodayForSameDay() {
        let now = Date()
        let snapshot = DailySnapshot(steps: 5_000, goal: 7_000, date: now)
        XCTAssertTrue(snapshot.isFromToday(now, calendar: cal))
    }

    func testIsFromTodayEarlierSameDay() {
        // A snapshot written this morning is still "today" this evening.
        let now = Date()
        let startOfDay = cal.startOfDay(for: now)
        let snapshot = DailySnapshot(steps: 5_000, goal: 7_000, date: startOfDay)
        XCTAssertTrue(snapshot.isFromToday(now, calendar: cal))
    }

    func testIsFromTodayFalseForYesterday() {
        let now = Date()
        let yesterday = cal.date(byAdding: .day, value: -1, to: now)!
        let snapshot = DailySnapshot(steps: 9_999, goal: 7_000, date: yesterday)
        XCTAssertFalse(snapshot.isFromToday(now, calendar: cal))
    }

    func testProgressClampsToOne() {
        let snapshot = DailySnapshot(steps: 14_000, goal: 7_000, date: Date())
        XCTAssertEqual(snapshot.progress, 1.0, accuracy: 0.0001)
    }

    func testProgressZeroWhenGoalZero() {
        let snapshot = DailySnapshot(steps: 5_000, goal: 0, date: Date())
        XCTAssertEqual(snapshot.progress, 0)
    }

    func testDecodeToleratesMissingWeekKey() throws {
        // Older builds wrote snapshots without a `week` key — decode must not throw.
        let legacy = #"{"steps":4200,"goal":7000,"date":0}"#.data(using: .utf8)!
        let snapshot = try JSONDecoder().decode(DailySnapshot.self, from: legacy)
        XCTAssertEqual(snapshot.steps, 4_200)
        XCTAssertEqual(snapshot.goal, 7_000)
        XCTAssertEqual(snapshot.week, [])
    }

    func testRoundTripEncodePreservesWeek() throws {
        let snapshot = DailySnapshot(steps: 6_100, goal: 7_000, date: Date(), week: [1, 2, 3, 4, 5, 6, 7])
        let data = try JSONEncoder().encode(snapshot)
        let decoded = try JSONDecoder().decode(DailySnapshot.self, from: data)
        XCTAssertEqual(decoded.week, [1, 2, 3, 4, 5, 6, 7])
        XCTAssertEqual(decoded.steps, 6_100)
    }
}
