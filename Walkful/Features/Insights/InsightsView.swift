import SwiftUI

struct InsightsView: View {
    var settings: AppSettings
    var health: HealthKitService
    var store: Store

    @State private var showingPaywall = false
    @State private var range: TrendRange = .month
    private let heatmapDays = 364

    enum TrendRange: String, CaseIterable, Identifiable {
        case week = "Week", month = "Month", year = "Year"
        var id: String { rawValue }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Tokens.Spacing.xl) {
                if health.authState != .authorized {
                    connectCard
                } else if !store.isPro {
                    locked
                } else {
                    actionCard
                    trends
                    yearHeatmap
                    chips
                    mobility
                    activeMinutes
                    records
                    recap
                    lifetime
                }
            }
            .padding(Tokens.Spacing.lg)
        }
        .background(Tokens.Gradient.heroBackdrop.ignoresSafeArea())
        .safeAreaInset(edge: .top) { header }
        .sheet(isPresented: $showingPaywall) { PaywallView(store: store) }
        .task {
            if LaunchArgs.screenshots { return }
            if health.authState == .authorized, store.isPro { await health.loadInsights() }
        }
    }

    private var locked: some View {
        Card {
            VStack(alignment: .leading, spacing: Tokens.Spacing.md) {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(Tokens.Palette.primary)
                Text("Insights are part of Walkful Pro")
                    .font(Tokens.TextStyle.title)
                    .foregroundStyle(Tokens.Palette.textPrimary)
                Text("Consistency heatmap, best time of day, brisk-minute trends and lifetime distance. A one-time unlock.")
                    .font(Tokens.TextStyle.subheadline)
                    .foregroundStyle(Tokens.Palette.textSecondary)
                PrimaryButton(title: "Unlock Walkful Pro") { showingPaywall = true }
                    .padding(.top, Tokens.Spacing.xs)
            }
        }
    }

    private var connectCard: some View {
        Card {
            VStack(alignment: .leading, spacing: Tokens.Spacing.sm) {
                Text("Connect Apple Health")
                    .font(Tokens.TextStyle.title)
                    .foregroundStyle(Tokens.Palette.textPrimary)
                Text("Connect on the Today tab to unlock your insights.")
                    .font(Tokens.TextStyle.subheadline)
                    .foregroundStyle(Tokens.Palette.textSecondary)
            }
        }
    }

    // MARK: - Actionable insight

    private struct Insight {
        let icon: String
        let title: String
        let message: String
        var actionTitle: String?
        var action: (() -> Void)?
    }

    private var actionableInsight: Insight? {
        // 1) Not getting reminders → suggest turning them on, tied to the weakest weekday.
        if !settings.nudgesEnabled, let day = health.weakestWeekday() {
            return Insight(
                icon: "bell.badge",
                title: "Build a consistent habit",
                message: "You tend to move least on \(day)s. Gentle reminders help you stay on track.",
                actionTitle: "Turn on reminders",
                action: enableNudges
            )
        }
        // 2) On a streak → keep it alive.
        let current = health.currentStreak(goal: settings.dailyGoal)
        let longest = health.longestStreak(goal: settings.dailyGoal)
        if current >= 3 {
            let tail = current < longest ? " Your best is \(longest)." : " That's your best ever!"
            return Insight(
                icon: "flame",
                title: "Keep your streak alive",
                message: "You're on a \(current)-day streak.\(tail) A walk today keeps it going.")
        }
        // 3) Best time of day → plan around it.
        if let time = health.bestTimeOfDay {
            return Insight(
                icon: "clock",
                title: "Your best time",
                message: "You move most in the \(time.lowercased()). Planning a walk then makes it easier to hit your goal.")
        }
        return nil
    }

    @ViewBuilder private var actionCard: some View {
        if let insight = actionableInsight {
            Card {
                VStack(alignment: .leading, spacing: Tokens.Spacing.sm) {
                    HStack(spacing: Tokens.Spacing.sm) {
                        Image(systemName: insight.icon)
                            .foregroundStyle(Tokens.Palette.primary)
                        Text(insight.title)
                            .font(Tokens.TextStyle.headline)
                            .foregroundStyle(Tokens.Palette.textPrimary)
                    }
                    Text(insight.message)
                        .font(Tokens.TextStyle.subheadline)
                        .foregroundStyle(Tokens.Palette.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    if let actionTitle = insight.actionTitle {
                        Button(actionTitle) { insight.action?() }
                            .font(Tokens.TextStyle.subheadlineSemibold)
                            .foregroundStyle(Tokens.Palette.primary)
                            .padding(.top, Tokens.Spacing.xs)
                    }
                }
            }
        }
    }

    private func enableNudges() {
        settings.nudgesEnabled = true
        let start = settings.nudgeStartHour
        let end = settings.nudgeEndHour
        Task { await NudgeScheduler.reschedule(enabled: true, startHour: start, endHour: end) }
    }

    // MARK: - Trends (week / month / year)

    private var trendValues: [Int] {
        switch range {
        case .week: return health.recentDays(7).map(\.steps)
        case .month: return health.recentDays(30).map(\.steps)
        case .year: return health.monthlyTotals(12)
        }
    }

    private var trendCaption: String {
        let vals = trendValues
        guard !vals.isEmpty else { return "No data yet" }
        let avg = vals.reduce(0, +) / vals.count
        return "Steps · avg \(avg.stepsFormatted)/\(range == .year ? "month" : "day")"
    }

    private var trends: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.md) {
            Picker("Range", selection: $range) {
                ForEach(TrendRange.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            Text(trendCaption)
                .font(Tokens.TextStyle.caption)
                .foregroundStyle(Tokens.Palette.textTertiary)
            TrendChartView(values: trendValues)
        }
    }

    // MARK: - Consistency (year heatmap)

    private var yearHeatmap: some View {
        let days = health.recentDays(heatmapDays)
        let atGoal = health.daysAtGoal(lastDays: heatmapDays, goal: settings.dailyGoal)
        return VStack(alignment: .leading, spacing: Tokens.Spacing.md) {
            HStack {
                Text("Consistency")
                    .font(Tokens.TextStyle.subheadlineSemibold)
                    .foregroundStyle(Tokens.Palette.textPrimary)
                Spacer()
                Text("\(atGoal) of \(max(days.count, 1)) days at goal")
                    .font(Tokens.TextStyle.caption)
                    .foregroundStyle(Tokens.Palette.textTertiary)
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 3), count: 19), spacing: 3) {
                ForEach(days) { day in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(cellColor(day.steps))
                        .aspectRatio(1, contentMode: .fit)
                }
            }
            .accessibilityHidden(true) // decorative; the count above is read by VoiceOver
        }
    }

    private func cellColor(_ steps: Int) -> Color {
        let goal = settings.dailyGoal
        if steps >= goal { return Tokens.Palette.primary }
        if steps >= goal / 2 { return Tokens.Palette.primary.opacity(0.35) }
        return Tokens.Palette.mutedFill
    }

    // MARK: - Chips (best time + resting HR / longest streak)

    private var chips: some View {
        HStack(spacing: Tokens.Spacing.sm) {
            StatChip(value: health.bestTimeOfDay ?? "—", unit: nil, label: "best time")
            StatChip(value: "\(health.longestStreak(goal: settings.dailyGoal))",
                     unit: "days", label: "longest streak")
        }
    }

    // MARK: - Mobility & fitness (Apple Watch-derived; cards hidden when absent)

    private struct Metric: Identifiable {
        let id = UUID()
        let value: String
        let unit: String?
        let label: String
        var accent = false
    }

    private var mobilityMetrics: [Metric] {
        var metrics: [Metric] = []
        if let speed = health.walkingSpeed {
            metrics.append(Metric(value: String(format: "%.1f", speed), unit: "m/s", label: "walking speed"))
        }
        if let steady = health.walkingSteadiness {
            let pct = Int((steady * 100).rounded())
            metrics.append(Metric(value: pct >= 50 ? "OK" : "Low", unit: nil,
                                  label: "steadiness", accent: pct >= 50))
        }
        if let vo2 = health.vo2Max {
            metrics.append(Metric(value: "\(Int(vo2.rounded()))", unit: nil, label: "cardio (VO₂max)"))
        }
        if let hr = health.restingHeartRate {
            metrics.append(Metric(value: "\(hr)", unit: "bpm", label: "resting HR"))
        }
        return metrics
    }

    @ViewBuilder private var mobility: some View {
        let metrics = mobilityMetrics
        if !metrics.isEmpty {
            VStack(alignment: .leading, spacing: Tokens.Spacing.md) {
                Text("Mobility & fitness")
                    .font(Tokens.TextStyle.subheadlineSemibold)
                    .foregroundStyle(Tokens.Palette.textPrimary)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: Tokens.Spacing.sm), count: 2),
                          spacing: Tokens.Spacing.sm) {
                    ForEach(metrics) { m in
                        StatChip(value: m.value, unit: m.unit, label: m.label, accent: m.accent)
                    }
                }
            }
        }
    }

    // MARK: - Active minutes trend

    private var activeMinutes: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.md) {
            Text("Brisk minutes · last 4 weeks")
                .font(Tokens.TextStyle.subheadlineSemibold)
                .foregroundStyle(Tokens.Palette.textPrimary)
            if health.activeMinutesByWeek.allSatisfy({ $0 == 0 }) {
                Text("No active minutes recorded yet.")
                    .font(Tokens.TextStyle.subheadline)
                    .foregroundStyle(Tokens.Palette.textTertiary)
            } else {
                WeekBars(values: health.activeMinutesByWeek,
                         scaleMax: health.activeMinutesByWeek.max() ?? 1,
                         height: 48)
            }
        }
    }

    // MARK: - Records gallery

    private var records: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.md) {
            Text("Records")
                .font(Tokens.TextStyle.subheadlineSemibold)
                .foregroundStyle(Tokens.Palette.textPrimary)
            VStack(spacing: 0) {
                recordRow("Best day", health.bestDaySteps.stepsFormatted)
                recordRow("Best week", health.bestWeekTotal.stepsFormatted)
                recordRow("Best month", health.bestMonthSteps.stepsFormatted)
                recordRow("Longest streak", "\(health.longestStreak(goal: settings.dailyGoal)) days")
                recordRow("Most floors", "\(health.mostFloorsInADay)")
            }
        }
    }

    private func recordRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(Tokens.TextStyle.subheadline)
                .foregroundStyle(Tokens.Palette.textPrimary)
            Spacer()
            Text(value)
                .font(Tokens.TextStyle.subheadlineSemibold)
                .foregroundStyle(Tokens.Palette.accentText)
        }
        .padding(.vertical, Tokens.Spacing.sm)
        .overlay(alignment: .bottom) {
            Rectangle().fill(Tokens.Palette.borderSubtle).frame(height: 0.5)
        }
    }

    // MARK: - Monthly recap

    @ViewBuilder private var recap: some View {
        if health.thisMonthSteps > 0 {
            Card {
                VStack(alignment: .leading, spacing: Tokens.Spacing.xs) {
                    Text("This month")
                        .font(Tokens.TextStyle.subheadline)
                        .foregroundStyle(Tokens.Palette.textSecondary)
                    Text("\(health.thisMonthSteps.stepsFormatted) steps")
                        .font(Tokens.TextStyle.titleNumber)
                        .foregroundStyle(Tokens.Palette.accentText)
                    Text(recapDelta)
                        .font(Tokens.TextStyle.subheadline)
                        .foregroundStyle(Tokens.Palette.textPrimary)
                }
            }
        }
    }

    private var recapDelta: String {
        guard health.lastMonthSteps > 0 else { return "Your first month of data — every step counts." }
        let diff = health.thisMonthSteps - health.lastMonthSteps
        let pct = Int((Double(abs(diff)) / Double(health.lastMonthSteps) * 100).rounded())
        return diff >= 0 ? "Up \(pct)% on last month." : "Down \(pct)% on last month — keep going."
    }

    // MARK: - Lifetime milestone

    private var lifetime: some View {
        let km = health.lifetimeDistanceKm
        let marathons = Int((km / 42.195).rounded())
        return Card {
            VStack(alignment: .leading, spacing: Tokens.Spacing.xs) {
                Text("Lifetime distance")
                    .font(Tokens.TextStyle.subheadline)
                    .foregroundStyle(Tokens.Palette.textSecondary)
                Text("\(Int(Units.distance(km: km, imperial: settings.useImperial)).stepsFormatted) \(Units.label(imperial: settings.useImperial))")
                    .font(Tokens.TextStyle.titleNumber)
                    .foregroundStyle(Tokens.Palette.accentText)
                if marathons >= 1 {
                    Text("That's \(marathons) marathon\(marathons == 1 ? "" : "s"). Keep wending.")
                        .font(Tokens.TextStyle.subheadline)
                        .foregroundStyle(Tokens.Palette.textPrimary)
                }
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text("Insights")
                .font(Tokens.TextStyle.title)
                .foregroundStyle(Tokens.Palette.textPrimary)
            Spacer()
        }
        .padding(.horizontal, Tokens.Spacing.lg)
        .padding(.vertical, Tokens.Spacing.md)
        .background(.ultraThinMaterial)
    }
}
