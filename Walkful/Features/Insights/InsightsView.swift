import SwiftUI

struct InsightsView: View {
    var settings: AppSettings
    var health: HealthKitService

    private let window = 30

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Tokens.Spacing.xl) {
                if health.authState == .authorized {
                    consistency
                    chips
                    activeMinutes
                    lifetime
                } else {
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
            }
            .padding(Tokens.Spacing.lg)
        }
        .background(Tokens.Palette.appBackground)
        .safeAreaInset(edge: .top) { header }
        .task {
            if health.authState == .authorized { await health.loadInsights() }
        }
    }

    // MARK: - Consistency heatmap

    private var consistency: some View {
        let days = health.recentDays(window)
        let atGoal = health.daysAtGoal(lastDays: window, goal: settings.dailyGoal)
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
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 10), spacing: 4) {
                ForEach(days) { day in
                    RoundedRectangle(cornerRadius: 3)
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
            if let hr = health.restingHeartRate {
                StatChip(value: "\(hr)", unit: "bpm", label: "resting HR")
            } else {
                StatChip(value: "\(health.longestStreak(goal: settings.dailyGoal))",
                         unit: "days", label: "longest streak")
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
