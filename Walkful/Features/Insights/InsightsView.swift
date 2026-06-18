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
                    trends
                    yearHeatmap
                    chips
                    mobility
                    activeMinutes
                    lifetime
                }
            }
            .padding(Tokens.Spacing.lg)
        }
        .background(Tokens.Palette.appBackground)
        .safeAreaInset(edge: .top) { header }
        .sheet(isPresented: $showingPaywall) { PaywallView(store: store) }
        .task {
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
                    .font(.system(size: Tokens.FontSize.lg, weight: .semibold))
                    .foregroundStyle(Tokens.Palette.textPrimary)
                Text("Consistency heatmap, best time of day, brisk-minute trends and lifetime distance. A one-time unlock.")
                    .font(.system(size: Tokens.FontSize.sm))
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
                    .font(.system(size: Tokens.FontSize.lg, weight: .semibold))
                    .foregroundStyle(Tokens.Palette.textPrimary)
                Text("Connect on the Today tab to unlock your insights.")
                    .font(.system(size: Tokens.FontSize.sm))
                    .foregroundStyle(Tokens.Palette.textSecondary)
            }
        }
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
                .font(.system(size: Tokens.FontSize.xs))
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
                    .font(.system(size: Tokens.FontSize.sm, weight: .semibold))
                    .foregroundStyle(Tokens.Palette.textPrimary)
                Spacer()
                Text("\(atGoal) of \(max(days.count, 1)) days at goal")
                    .font(.system(size: Tokens.FontSize.xs))
                    .foregroundStyle(Tokens.Palette.textTertiary)
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 3), count: 19), spacing: 3) {
                ForEach(days) { day in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(cellColor(day.steps))
                        .aspectRatio(1, contentMode: .fit)
                }
            }
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
                    .font(.system(size: Tokens.FontSize.sm, weight: .semibold))
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
                .font(.system(size: Tokens.FontSize.sm, weight: .semibold))
                .foregroundStyle(Tokens.Palette.textPrimary)
            if health.activeMinutesByWeek.allSatisfy({ $0 == 0 }) {
                Text("No active minutes recorded yet.")
                    .font(.system(size: Tokens.FontSize.sm))
                    .foregroundStyle(Tokens.Palette.textTertiary)
            } else {
                WeekBars(values: health.activeMinutesByWeek,
                         scaleMax: health.activeMinutesByWeek.max() ?? 1,
                         height: 48)
            }
        }
    }

    // MARK: - Lifetime milestone

    private var lifetime: some View {
        let km = health.lifetimeDistanceKm
        let marathons = Int((km / 42.195).rounded())
        return Card {
            VStack(alignment: .leading, spacing: Tokens.Spacing.xs) {
                Text("Lifetime distance")
                    .font(.system(size: Tokens.FontSize.sm))
                    .foregroundStyle(Tokens.Palette.textSecondary)
                Text("\(Int(km).stepsFormatted) km")
                    .font(.system(size: Tokens.FontSize.xl, weight: .semibold))
                    .foregroundStyle(Tokens.Palette.accentText)
                if marathons >= 1 {
                    Text("That's \(marathons) marathon\(marathons == 1 ? "" : "s"). Keep wending.")
                        .font(.system(size: Tokens.FontSize.sm))
                        .foregroundStyle(Tokens.Palette.textPrimary)
                }
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text("Insights")
                .font(.system(size: Tokens.FontSize.lg, weight: .semibold))
                .foregroundStyle(Tokens.Palette.textPrimary)
            Spacer()
        }
        .padding(.horizontal, Tokens.Spacing.lg)
        .padding(.vertical, Tokens.Spacing.md)
        .background(Tokens.Palette.appBackground)
    }
}
