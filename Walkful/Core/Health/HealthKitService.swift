import Foundation
import HealthKit
import Observation

/// Læser sundhedsdata fra HealthKit. Kun læse-adgang, granulært samtykke.
/// Alt bliver på enheden — vi gemmer eller sender intet.
@MainActor
@Observable
final class HealthKitService {

    enum AuthState {
        case unknown, authorized, denied, unavailable
    }

    struct DayStat: Identifiable {
        var id: Date { date }
        let date: Date
        let steps: Int
    }

    private let store = HKHealthStore()
    private let stepType = HKQuantityType(.stepCount)
    private let distanceType = HKQuantityType(.distanceWalkingRunning)
    private let floorsType = HKQuantityType(.flightsClimbed)
    private let exerciseType = HKQuantityType(.appleExerciseTime)
    private let restingHRType = HKQuantityType(.restingHeartRate)
    private let walkingSpeedType = HKQuantityType(.walkingSpeed)
    private let steadinessType = HKQuantityType(.appleWalkingSteadiness)
    private let vo2MaxType = HKQuantityType(.vo2Max)

    // I dag
    var authState: AuthState = .unknown
    var todaySteps = 0
    var todayDistanceKm = 0.0
    var todayFloors = 0
    var todayActiveMinutes = 0

    // Uge & historik
    var weekDays: [DayStat] = []
    var thisWeekTotal = 0
    var lastWeekTotal = 0
    var bestWeekTotal = 0
    private var dailyHistory: [DayStat] = []

    // Insights
    var lifetimeDistanceKm = 0.0
    var bestTimeOfDay: String?
    var activeMinutesByWeek: [Int] = []
    var restingHeartRate: Int?

    // Mobilitet & form (nil = ingen data, fx ingen Apple Watch → kort skjules)
    var walkingSpeed: Double?      // m/s
    var walkingSteadiness: Double? // 0...1
    var vo2Max: Double?            // ml/(kg·min)

    // Rekorder & recap
    var bestDaySteps = 0
    var bestMonthSteps = 0
    var mostFloorsInADay = 0
    var thisMonthSteps = 0
    var lastMonthSteps = 0

    private var observer: HKObserverQuery?

    var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }

    // MARK: - Auth

    func requestAuthorization() async {
        guard isAvailable else { authState = .unavailable; return }
        let readTypes: Set<HKObjectType> = [
            stepType, distanceType, floorsType, exerciseType, restingHRType,
            walkingSpeedType, steadinessType, vo2MaxType
        ]
        do {
            try await store.requestAuthorization(toShare: [], read: readTypes)
            authState = .authorized
            await refreshToday()
            startObserving()
        } catch {
            authState = .denied
        }
    }

    // MARK: - I dag

    func refreshToday() async {
        async let steps = sum(stepType, unit: .count())
        async let dist = sum(distanceType, unit: .meterUnit(with: .kilo))
        async let floors = sum(floorsType, unit: .count())
        async let active = sum(exerciseType, unit: .minute())
        todaySteps = Int(await steps)
        todayDistanceKm = await dist
        todayFloors = Int(await floors)
        todayActiveMinutes = Int(await active)
    }

    private func sum(_ type: HKQuantityType, unit: HKUnit, from start: Date? = nil) async -> Double {
        let startDate = start ?? Calendar.current.startOfDay(for: .now)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: .now)
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, stats, _ in
                continuation.resume(returning: stats?.sumQuantity()?.doubleValue(for: unit) ?? 0)
            }
            store.execute(query)
        }
    }

    // MARK: - Uge & historik

    private func isoCalendar() -> Calendar {
        var cal = Calendar(identifier: .iso8601)
        cal.timeZone = .current
        return cal
    }

    nonisolated private static func weekStart(_ date: Date, _ cal: Calendar) -> Date {
        cal.dateInterval(of: .weekOfYear, for: date)?.start ?? cal.startOfDay(for: date)
    }

    func loadHistory(weeks: Int = 53) async {
        let cal = isoCalendar()
        let thisWeekStart = Self.weekStart(cal.startOfDay(for: .now), cal)
        guard let start = cal.date(byAdding: .day, value: -7 * weeks, to: thisWeekStart) else { return }

        let daily = await dailySteps(from: start, cal: cal)
        dailyHistory = daily

        var weekly: [Date: Int] = [:]
        for day in daily { weekly[Self.weekStart(day.date, cal), default: 0] += day.steps }

        let lastWeekStart = cal.date(byAdding: .day, value: -7, to: thisWeekStart) ?? thisWeekStart
        thisWeekTotal = weekly[thisWeekStart] ?? 0
        lastWeekTotal = weekly[lastWeekStart] ?? 0
        bestWeekTotal = weekly.values.max() ?? 0
        weekDays = daily.filter { $0.date >= thisWeekStart }
    }

    private func byDay() -> [Date: Int] {
        let cal = isoCalendar()
        return Dictionary(dailyHistory.map { (cal.startOfDay(for: $0.date), $0.steps) },
                          uniquingKeysWith: { a, _ in a })
    }

    func currentStreak(goal: Int) -> Int {
        let cal = isoCalendar()
        let map = byDay()
        var day = cal.startOfDay(for: .now)
        if (map[day] ?? 0) < goal {
            day = cal.date(byAdding: .day, value: -1, to: day) ?? day
        }
        var streak = 0
        while let steps = map[day], steps >= goal {
            streak += 1
            guard let prev = cal.date(byAdding: .day, value: -1, to: day) else { break }
            day = prev
        }
        return streak
    }

    func longestStreak(goal: Int) -> Int {
        let sorted = dailyHistory.sorted { $0.date < $1.date }
        var best = 0, run = 0
        for day in sorted {
            if day.steps >= goal { run += 1; best = max(best, run) } else { run = 0 }
        }
        return best
    }

    /// De seneste n dage (ældst→nyest), til heatmap.
    func recentDays(_ n: Int) -> [DayStat] {
        Array(dailyHistory.sorted { $0.date < $1.date }.suffix(n))
    }

    func daysAtGoal(lastDays n: Int, goal: Int) -> Int {
        recentDays(n).filter { $0.steps >= goal }.count
    }

    /// The weekday (English name) you move least on, by average steps. nil if no history.
    func weakestWeekday() -> String? {
        guard !dailyHistory.isEmpty else { return nil }
        let cal = isoCalendar()
        var totals: [Int: (sum: Int, count: Int)] = [:]
        for day in dailyHistory {
            let wd = cal.component(.weekday, from: day.date) // 1 = Sunday
            let e = totals[wd] ?? (0, 0)
            totals[wd] = (e.sum + day.steps, e.count + 1)
        }
        guard let weakest = totals.min(by: {
            Double($0.value.sum) / Double($0.value.count) < Double($1.value.sum) / Double($1.value.count)
        })?.key else { return nil }
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "en_US")
        return fmt.weekdaySymbols[weakest - 1] // weekdaySymbols[0] = Sunday
    }

    #if DEBUG
    /// Test seam: inject a known daily history (used by unit tests and screenshots).
    func setDailyHistoryForTesting(_ days: [DayStat]) { dailyHistory = days }
    #endif

    var weekAveragePerDay: Int {
        guard !weekDays.isEmpty else { return 0 }
        return weekDays.map(\.steps).reduce(0, +) / weekDays.count
    }

    /// Monthly step totals (oldest→newest) for the year trend.
    func monthlyTotals(_ months: Int = 12) -> [Int] {
        let cal = Calendar.current
        var byMonth: [Date: Int] = [:]
        for day in dailyHistory {
            let comps = cal.dateComponents([.year, .month], from: day.date)
            if let monthStart = cal.date(from: comps) {
                byMonth[monthStart, default: 0] += day.steps
            }
        }
        return byMonth.keys.sorted().suffix(months).map { byMonth[$0] ?? 0 }
    }

    // MARK: - Insights

    func loadInsights() async {
        if dailyHistory.isEmpty { await loadHistory() }
        async let lifetime = sum(distanceType, unit: .meterUnit(with: .kilo), from: Date.distantPast)
        async let best = computeBestTimeOfDay()
        async let weekly = computeActiveMinutesByWeek()
        async let resting = computeRestingHeartRate()
        async let speed = discreteAverage(walkingSpeedType, unit: .meter().unitDivided(by: .second()), days: 7)
        async let steady = discreteAverage(steadinessType, unit: .percent(), days: 30)
        async let vo2 = discreteAverage(vo2MaxType, unit: HKUnit(from: "ml/kg*min"), days: 90)
        async let floors = maxDailyFloors()
        lifetimeDistanceKm = await lifetime
        bestTimeOfDay = await best
        activeMinutesByWeek = await weekly
        restingHeartRate = await resting
        walkingSpeed = await speed
        walkingSteadiness = await steady
        vo2Max = await vo2
        mostFloorsInADay = await floors

        // Records & recap (from the loaded daily history)
        bestDaySteps = dailyHistory.map(\.steps).max() ?? 0
        let months = monthlyTotals(120)
        bestMonthSteps = months.max() ?? 0
        thisMonthSteps = months.last ?? 0
        lastMonthSteps = months.count >= 2 ? months[months.count - 2] : 0
    }

    private func maxDailyFloors() async -> Int {
        let cal = isoCalendar()
        guard let start = cal.date(byAdding: .day, value: -371, to: cal.startOfDay(for: .now)) else { return 0 }
        var interval = DateComponents(); interval.day = 1
        let predicate = HKQuery.predicateForSamples(withStart: start, end: .now)
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsCollectionQuery(
                quantityType: floorsType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum,
                anchorDate: cal.startOfDay(for: .now),
                intervalComponents: interval
            )
            query.initialResultsHandler = { _, results, _ in
                var maxFloors = 0.0
                results?.enumerateStatistics(from: start, to: .now) { stats, _ in
                    maxFloors = max(maxFloors, stats.sumQuantity()?.doubleValue(for: .count()) ?? 0)
                }
                continuation.resume(returning: Int(maxFloors))
            }
            store.execute(query)
        }
    }

    private func discreteAverage(_ type: HKQuantityType, unit: HKUnit, days: Int) async -> Double? {
        let start = Calendar.current.date(byAdding: .day, value: -days, to: .now) ?? .now
        let predicate = HKQuery.predicateForSamples(withStart: start, end: .now)
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: .discreteAverage
            ) { _, stats, _ in
                continuation.resume(returning: stats?.averageQuantity()?.doubleValue(for: unit))
            }
            store.execute(query)
        }
    }

    private func dailySteps(from start: Date, cal: Calendar) async -> [DayStat] {
        let anchor = cal.startOfDay(for: .now)
        var interval = DateComponents(); interval.day = 1
        let predicate = HKQuery.predicateForSamples(withStart: start, end: .now)
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsCollectionQuery(
                quantityType: stepType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum,
                anchorDate: anchor,
                intervalComponents: interval
            )
            query.initialResultsHandler = { _, results, _ in
                var out: [DayStat] = []
                results?.enumerateStatistics(from: start, to: .now) { stats, _ in
                    let value = stats.sumQuantity()?.doubleValue(for: .count()) ?? 0
                    out.append(DayStat(date: stats.startDate, steps: Int(value)))
                }
                continuation.resume(returning: out)
            }
            store.execute(query)
        }
    }

    /// Hvornår på dagen går du mest?
    private func computeBestTimeOfDay() async -> String? {
        let cal = isoCalendar()
        guard let start = cal.date(byAdding: .day, value: -14, to: cal.startOfDay(for: .now)) else { return nil }
        var interval = DateComponents(); interval.hour = 1
        let predicate = HKQuery.predicateForSamples(withStart: start, end: .now)
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsCollectionQuery(
                quantityType: stepType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum,
                anchorDate: cal.startOfDay(for: .now),
                intervalComponents: interval
            )
            query.initialResultsHandler = { _, results, _ in
                var buckets = [0.0, 0.0, 0.0, 0.0] // night, morning, afternoon, evening
                results?.enumerateStatistics(from: start, to: .now) { stats, _ in
                    let steps = stats.sumQuantity()?.doubleValue(for: .count()) ?? 0
                    switch cal.component(.hour, from: stats.startDate) {
                    case 5..<12: buckets[1] += steps
                    case 12..<17: buckets[2] += steps
                    case 17..<22: buckets[3] += steps
                    default: buckets[0] += steps
                    }
                }
                let labels = ["Late night", "Mornings", "Afternoons", "Evenings"]
                guard let maxIdx = buckets.indices.max(by: { buckets[$0] < buckets[$1] }),
                      buckets[maxIdx] > 0 else {
                    continuation.resume(returning: nil); return
                }
                continuation.resume(returning: labels[maxIdx])
            }
            store.execute(query)
        }
    }

    private func computeActiveMinutesByWeek(weeks: Int = 4) async -> [Int] {
        let cal = isoCalendar()
        let thisWeekStart = Self.weekStart(cal.startOfDay(for: .now), cal)
        guard let start = cal.date(byAdding: .day, value: -7 * (weeks - 1), to: thisWeekStart) else { return [] }
        var interval = DateComponents(); interval.day = 1
        let predicate = HKQuery.predicateForSamples(withStart: start, end: .now)
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsCollectionQuery(
                quantityType: exerciseType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum,
                anchorDate: cal.startOfDay(for: .now),
                intervalComponents: interval
            )
            query.initialResultsHandler = { _, results, _ in
                var weekly: [Date: Int] = [:]
                results?.enumerateStatistics(from: start, to: .now) { stats, _ in
                    let mins = stats.sumQuantity()?.doubleValue(for: .minute()) ?? 0
                    weekly[Self.weekStart(stats.startDate, cal), default: 0] += Int(mins)
                }
                continuation.resume(returning: weekly.keys.sorted().map { weekly[$0] ?? 0 })
            }
            store.execute(query)
        }
    }

    private func computeRestingHeartRate() async -> Int? {
        let cal = isoCalendar()
        guard let start = cal.date(byAdding: .day, value: -7, to: cal.startOfDay(for: .now)) else { return nil }
        let predicate = HKQuery.predicateForSamples(withStart: start, end: .now)
        let unit = HKUnit.count().unitDivided(by: .minute())
        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: restingHRType,
                quantitySamplePredicate: predicate,
                options: .discreteAverage
            ) { _, stats, _ in
                if let avg = stats?.averageQuantity()?.doubleValue(for: unit), avg > 0 {
                    continuation.resume(returning: Int(avg.rounded()))
                } else {
                    continuation.resume(returning: nil)
                }
            }
            store.execute(query)
        }
    }

    #if DEBUG
    /// Fills the service with realistic sample data for App Store screenshots.
    func loadSampleData() {
        let cal = isoCalendar()
        let today = cal.startOfDay(for: .now)
        var hist: [DayStat] = []
        for i in stride(from: 364, through: 0, by: -1) {
            let date = cal.date(byAdding: .day, value: -i, to: today) ?? today
            let x = Double(364 - i)
            let steps = Int(7200 + 2600 * sin(x / 9.0) + 1500 * sin(x / 40.0))
            hist.append(DayStat(date: date, steps: max(800, steps)))
        }
        dailyHistory = hist
        authState = .authorized

        todaySteps = hist.last?.steps ?? 8_240
        todayDistanceKm = Double(todaySteps) * 0.00072
        todayFloors = 11
        todayActiveMinutes = 38

        let tws = Self.weekStart(today, cal)
        var weekly: [Date: Int] = [:]
        for day in hist { weekly[Self.weekStart(day.date, cal), default: 0] += day.steps }
        let lws = cal.date(byAdding: .day, value: -7, to: tws) ?? tws
        thisWeekTotal = weekly[tws] ?? 0
        lastWeekTotal = weekly[lws] ?? 0
        bestWeekTotal = weekly.values.max() ?? 0
        weekDays = hist.filter { $0.date >= tws }

        bestDaySteps = hist.map(\.steps).max() ?? 0
        let months = monthlyTotals(120)
        bestMonthSteps = months.max() ?? 0
        thisMonthSteps = months.last ?? 0
        lastMonthSteps = months.count >= 2 ? months[months.count - 2] : 0
        mostFloorsInADay = 28

        bestTimeOfDay = "Mornings"
        activeMinutesByWeek = [120, 150, 165, 190]
        restingHeartRate = 58
        walkingSpeed = 1.4
        walkingSteadiness = 0.82
        vo2Max = 43
        lifetimeDistanceKm = 2_140
    }
    #endif

    // MARK: - Live opdatering

    private func startObserving() {
        guard observer == nil else { return }
        let query = HKObserverQuery(sampleType: stepType, predicate: nil) { [weak self] _, completion, _ in
            Task { await self?.refreshToday() }
            completion()
        }
        store.execute(query)
        observer = query
    }
}
