import XCTest
@testable import Walkful

@MainActor
final class HealthStatsTests: XCTestCase {

    private let cal = Calendar(identifier: .iso8601)

    /// A DayStat `offset` days from today (0 = today, -1 = yesterday).
    private func day(_ offset: Int, _ steps: Int) -> HealthKitService.DayStat {
        let date = cal.date(byAdding: .day, value: offset, to: cal.startOfDay(for: Date()))!
        return .init(date: date, steps: steps)
    }

    private func service(_ days: [HealthKitService.DayStat]) -> HealthKitService {
        let s = HealthKitService()
        s.setDailyHistoryForTesting(days)
        return s
    }

    func testLongestStreak() {
        // goal 7000: met, met, missed, met, met → longest run = 2
        let s = service([day(-4, 8_000), day(-3, 7_500), day(-2, 3_000), day(-1, 9_000), day(0, 9_000)])
        XCTAssertEqual(s.longestStreak(goal: 7_000), 2)
    }

    func testLongestStreakAllMissed() {
        let s = service([day(-2, 1_000), day(-1, 2_000), day(0, 3_000)])
        XCTAssertEqual(s.longestStreak(goal: 7_000), 0)
    }

    func testCurrentStreakCountsTodayWhenMet() {
        let s = service([day(-2, 8_000), day(-1, 8_000), day(0, 8_000)])
        XCTAssertEqual(s.currentStreak(goal: 7_000), 3)
    }

    func testCurrentStreakIsGentleWhenTodayNotMetYet() {
        // Today below goal (day not over) — streak counts the prior met days.
        let s = service([day(-2, 8_000), day(-1, 8_000), day(0, 1_000)])
        XCTAssertEqual(s.currentStreak(goal: 7_000), 2)
    }

    func testDaysAtGoal() {
        let s = service([day(-2, 8_000), day(-1, 4_000), day(0, 9_000)])
        XCTAssertEqual(s.daysAtGoal(lastDays: 3, goal: 7_000), 2)
    }

    func testRecentDaysReturnsSuffixAscending() {
        let s = service([day(-3, 10), day(-2, 20), day(-1, 30), day(0, 40)])
        let last2 = s.recentDays(2)
        XCTAssertEqual(last2.map(\.steps), [30, 40])
    }

    func testWeakestWeekday() {
        let target = 4 // Wednesday (1 = Sunday)
        var days: [HealthKitService.DayStat] = []
        for off in stride(from: -27, through: 0, by: 1) {
            let date = cal.date(byAdding: .day, value: off, to: cal.startOfDay(for: Date()))!
            let wd = cal.component(.weekday, from: date)
            days.append(.init(date: date, steps: wd == target ? 1_000 : 9_000))
        }
        let s = service(days)
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "en_US")
        XCTAssertEqual(s.weakestWeekday(), fmt.weekdaySymbols[target - 1])
    }

    func testAdaptedGoalRaisesWhenAverageBeatsGoal() {
        // 8,000 avg vs 7,000 goal → 8,000 ≥ 7,700, so bump by 500.
        XCTAssertEqual(HealthKitService.adaptedGoal(current: 7_000, recentAverage: 8_000), 7_500)
    }

    func testAdaptedGoalHoldsWhenAverageOnlySlightlyAbove() {
        // 7,200 avg vs 7,000 goal → below the 110% threshold (7,700), no change.
        XCTAssertEqual(HealthKitService.adaptedGoal(current: 7_000, recentAverage: 7_200), 7_000)
    }

    func testAdaptedGoalRespectsCap() {
        XCTAssertEqual(HealthKitService.adaptedGoal(current: 12_000, recentAverage: 20_000), 12_000)
    }

    func testRecentAverageExcludesToday() {
        // Today is huge but partial-day should be ignored; avg of the two prior days = 6,000.
        let s = service([day(-2, 5_000), day(-1, 7_000), day(0, 50_000)])
        XCTAssertEqual(s.recentAverage(days: 14), 6_000)
    }

    func testMonthlyTotalsSumsRecentSteps() {
        // Both entries fall within the last 12 months → their steps are summed.
        // (Asserting the grand total avoids flaking on a month boundary.)
        let s = service([day(-1, 5_000), day(0, 6_000)])
        XCTAssertEqual(s.monthlyTotals(12).reduce(0, +), 11_000)
    }
}
