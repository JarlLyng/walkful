import SwiftUI
import WidgetKit

struct TodayView: View {
    var settings: AppSettings
    var health: HealthKitService

    @State private var showingCoach = false

    private var goal: Int { settings.dailyGoal }
    private var progress: Double {
        goal > 0 ? Double(health.todaySteps) / Double(goal) : 0
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Tokens.Spacing.xl) {
                switch health.authState {
                case .authorized:
                    dashboard
                case .unavailable:
                    infoCard(icon: "heart.slash", title: "Health data unavailable",
                             message: "This device doesn't provide Apple Health data.")
                default:
                    connectCard
                }
            }
            .padding(Tokens.Spacing.lg)
        }
        .background(Tokens.Palette.appBackground)
        .safeAreaInset(edge: .top) { header }
        .sheet(isPresented: $showingCoach) { CoachView() }
        .task {
            if health.authState == .authorized {
                await health.refreshToday()
                await health.loadHistory()
                publishToWidget()
            }
        }
        .onChange(of: health.todaySteps) { _, _ in publishToWidget() }
    }

    // MARK: - Dashboard

    private var dashboard: some View {
        Group {
            ZStack {
                ProgressRing(progress: progress)
                    .frame(width: 200, height: 200)
                VStack(spacing: 2) {
                    Text(health.todaySteps.stepsFormatted)
                        .font(.system(size: Tokens.FontSize.xxl, weight: .semibold))
                        .foregroundStyle(Tokens.Palette.textPrimary)
                    Text("of \(goal.stepsFormatted)")
                        .font(.system(size: Tokens.FontSize.sm))
                        .foregroundStyle(Tokens.Palette.textTertiary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, Tokens.Spacing.sm)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(health.todaySteps.stepsFormatted) of \(goal.stepsFormatted) steps today")
            .accessibilityValue("\(Int(progress * 100)) percent of your goal")

            Text(meaning)
                .font(.system(size: Tokens.FontSize.sm))
                .foregroundStyle(Tokens.Palette.accentText)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)

            LazyVGrid(columns: [GridItem(.flexible(), spacing: Tokens.Spacing.sm),
                                GridItem(.flexible(), spacing: Tokens.Spacing.sm)],
                      spacing: Tokens.Spacing.sm) {
                StatChip(value: String(format: "%.1f", health.todayDistanceKm), unit: "km", label: "distance")
                StatChip(value: "\(health.todayActiveMinutes)", unit: "min", label: "active", accent: true)
                StatChip(value: "\(health.todayFloors)", unit: nil, label: "floors")
                StatChip(value: health.weekAveragePerDay.stepsFormatted, unit: nil, label: "week avg")
            }

            Button {
                showingCoach = true
            } label: {
                HStack(spacing: Tokens.Spacing.md) {
                    Image(systemName: "figure.walk.motion")
                        .font(.system(size: 22))
                        .foregroundStyle(Tokens.Palette.primary)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Start an interval walk")
                            .font(.system(size: Tokens.FontSize.base, weight: .semibold))
                            .foregroundStyle(Tokens.Palette.textPrimary)
                        Text("3 min easy / 3 min brisk — boost your fitness")
                            .font(.system(size: Tokens.FontSize.sm))
                            .foregroundStyle(Tokens.Palette.textSecondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: Tokens.FontSize.sm))
                        .foregroundStyle(Tokens.Palette.textTertiary)
                }
                .padding(Tokens.Spacing.lg)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Tokens.Palette.primary.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.lg))
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: Tokens.Spacing.md) {
                HStack {
                    Text("This week")
                        .font(.system(size: Tokens.FontSize.sm, weight: .semibold))
                        .foregroundStyle(Tokens.Palette.textPrimary)
                    Spacer()
                    Text("\(health.thisWeekTotal.stepsFormatted) steps")
                        .font(.system(size: Tokens.FontSize.sm))
                        .foregroundStyle(Tokens.Palette.textTertiary)
                }
                if health.weekDays.isEmpty {
                    Text("No steps yet this week.")
                        .font(.system(size: Tokens.FontSize.sm))
                        .foregroundStyle(Tokens.Palette.textTertiary)
                } else {
                    WeekBars(values: health.weekDays.map(\.steps),
                             scaleMax: max(health.weekDays.map(\.steps).max() ?? 0, goal))
                }
            }

            let streak = health.currentStreak(goal: goal)
            if streak > 0 {
                Card {
                    HStack(spacing: Tokens.Spacing.md) {
                        Image(systemName: "flame")
                            .font(.system(size: 22))
                            .foregroundStyle(Tokens.Palette.primary)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(streak)-day streak")
                                .font(.system(size: Tokens.FontSize.base, weight: .semibold))
                                .foregroundStyle(Tokens.Palette.textPrimary)
                            Text("Your best is \(max(streak, health.longestStreak(goal: goal))) days.")
                                .font(.system(size: Tokens.FontSize.sm))
                                .foregroundStyle(Tokens.Palette.textSecondary)
                        }
                    }
                }
            }
        }
    }

    private func publishToWidget() {
        SharedStore.save(steps: health.todaySteps, goal: goal)
        WidgetCenter.shared.reloadAllTimelines()
    }

    private var meaning: String {
        switch health.todaySteps {
        case 7_000...: "In the zone linked to ~47% lower mortality."
        case 5_000..<7_000: "Past 5,000 — the real benefits kick in here."
        case 1..<5_000: "Every step counts — you're on your way."
        default: "Every step counts. Let's begin."
        }
    }

    // MARK: - States

    private var connectCard: some View {
        Card {
            VStack(alignment: .leading, spacing: Tokens.Spacing.md) {
                Image(systemName: "heart.text.square")
                    .font(.system(size: 28))
                    .foregroundStyle(Tokens.Palette.primary)
                Text("Connect Apple Health")
                    .font(.system(size: Tokens.FontSize.lg, weight: .semibold))
                    .foregroundStyle(Tokens.Palette.textPrimary)
                Text("Walkful reads your steps to show today's progress. Your data never leaves your device — we have no servers.")
                    .font(.system(size: Tokens.FontSize.sm))
                    .foregroundStyle(Tokens.Palette.textSecondary)
                PrimaryButton(title: "Connect") {
                    Task { await health.requestAuthorization() }
                }
                .padding(.top, Tokens.Spacing.xs)
            }
        }
    }

    private func infoCard(icon: String, title: String, message: String) -> some View {
        Card {
            VStack(alignment: .leading, spacing: Tokens.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundStyle(Tokens.Palette.textSecondary)
                Text(title)
                    .font(.system(size: Tokens.FontSize.lg, weight: .semibold))
                    .foregroundStyle(Tokens.Palette.textPrimary)
                Text(message)
                    .font(.system(size: Tokens.FontSize.sm))
                    .foregroundStyle(Tokens.Palette.textSecondary)
            }
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text("Today")
                    .font(.system(size: Tokens.FontSize.lg, weight: .semibold))
                    .foregroundStyle(Tokens.Palette.textPrimary)
                Text(Date.now.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated)))
                    .font(.system(size: Tokens.FontSize.xs))
                    .foregroundStyle(Tokens.Palette.textTertiary)
            }
            Spacer()
        }
        .padding(.horizontal, Tokens.Spacing.lg)
        .padding(.vertical, Tokens.Spacing.md)
        .background(Tokens.Palette.appBackground)
    }
}
