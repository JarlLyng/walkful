import SwiftUI
import WidgetKit
import StoreKit

struct TodayView: View {
    var settings: AppSettings
    var health: HealthKitService
    var store: Store

    @State private var showingCoach = false
    @State private var showingPaywall = false
    @State private var animatedProgress: Double = 0

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.requestReview) private var requestReview

    private var goal: Int { settings.dailyGoal }
    private var progress: Double {
        goal > 0 ? Double(health.todaySteps) / Double(goal) : 0
    }
    private var goalReached: Bool { goal > 0 && health.todaySteps >= goal }

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
        .background(Tokens.Gradient.heroBackdrop.ignoresSafeArea())
        .safeAreaInset(edge: .top) { header }
        .sheet(isPresented: $showingCoach) { CoachView() }
        .sheet(isPresented: $showingPaywall) { PaywallView(store: store) }
        .task {
            if LaunchArgs.screenshots { animatedProgress = progress; return }
            if health.authState == .authorized {
                await health.refreshToday()
                await health.loadHistory()
                if settings.adaptiveGoal {
                    settings.dailyGoal = HealthKitService.adaptedGoal(
                        current: settings.dailyGoal,
                        recentAverage: health.recentAverage(days: 14))
                }
                publishToWidget()
                syncProgress()
                maybeCelebrateGoal()
            }
        }
        .onChange(of: health.todaySteps) { _, _ in
            publishToWidget()
            syncProgress()
            maybeCelebrateGoal()
        }
    }

    /// Fyld ringen op til den aktuelle progress (animeret, med mindre Reduce Motion).
    private func syncProgress() {
        if reduceMotion {
            animatedProgress = progress
        } else {
            withAnimation(.easeInOut(duration: 0.6)) { animatedProgress = progress }
        }
    }

    /// Fejr at dagens mål er nået — én gang om dagen, med en success-haptik.
    private func maybeCelebrateGoal() {
        guard !LaunchArgs.screenshots, goalReached else { return }
        guard !Calendar.current.isDateInToday(settings.lastGoalCelebrationDay) else { return }
        settings.lastGoalCelebrationDay = .now
        Haptics.success()
        maybeAskForReview()
    }

    /// Ask for an App Store review at a genuine high point — the user just hit
    /// their goal *and* is on a 3+ day streak — and only ever once. The system
    /// further throttles how often the prompt actually appears.
    private func maybeAskForReview() {
        guard !settings.hasRequestedReview,
              health.currentStreak(goal: goal) >= 3 else { return }
        settings.hasRequestedReview = true
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.5))
            requestReview()
        }
    }

    // MARK: - Dashboard

    private var dashboard: some View {
        Group {
            ZStack {
                ProgressRing(progress: animatedProgress)
                    .frame(width: 200, height: 200)
                VStack(spacing: 2) {
                    Text(health.todaySteps.stepsFormatted)
                        .font(Tokens.TextStyle.hero)
                        .foregroundStyle(Tokens.Palette.textPrimary)
                    Text("of \(goal.stepsFormatted)")
                        .font(Tokens.TextStyle.subheadline)
                        .foregroundStyle(Tokens.Palette.textTertiary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, Tokens.Spacing.sm)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(health.todaySteps.stepsFormatted) of \(goal.stepsFormatted) steps today")
            .accessibilityValue("\(Int(progress * 100)) percent of your goal")

            if goalReached {
                Label("Goal reached today", systemImage: "checkmark.seal.fill")
                    .font(Tokens.TextStyle.subheadlineSemibold)
                    .foregroundStyle(Tokens.Palette.primary)
                    .padding(.horizontal, Tokens.Spacing.md)
                    .padding(.vertical, Tokens.Spacing.xs)
                    .background(Tokens.Palette.primary.opacity(0.12), in: Capsule())
                    .frame(maxWidth: .infinity)
                    .transition(.scale(scale: 0.85).combined(with: .opacity))
            }

            Text(meaning)
                .font(Tokens.TextStyle.subheadline)
                .foregroundStyle(Tokens.Palette.accentText)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)

            LazyVGrid(columns: [GridItem(.flexible(), spacing: Tokens.Spacing.sm),
                                GridItem(.flexible(), spacing: Tokens.Spacing.sm)],
                      spacing: Tokens.Spacing.sm) {
                StatChip(value: String(format: "%.1f", Units.distance(km: health.todayDistanceKm, imperial: settings.useImperial)), unit: Units.label(imperial: settings.useImperial), label: "distance")
                StatChip(value: "\(health.todayActiveMinutes)", unit: "min", label: "active", accent: true)
                StatChip(value: "\(health.todayFloors)", unit: nil, label: "floors")
                StatChip(value: health.weekAveragePerDay.stepsFormatted, unit: nil, label: "week avg")
            }

            Button {
                if store.isPro { showingCoach = true } else { showingPaywall = true }
            } label: {
                HStack(spacing: Tokens.Spacing.md) {
                    Image(systemName: "figure.walk.motion")
                        .font(.system(size: 22))
                        .foregroundStyle(Tokens.Palette.primary)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Start an interval walk")
                            .font(Tokens.TextStyle.headline)
                            .foregroundStyle(Tokens.Palette.textPrimary)
                        Text("3 min easy / 3 min brisk — boost your fitness")
                            .font(Tokens.TextStyle.subheadline)
                            .foregroundStyle(Tokens.Palette.textSecondary)
                    }
                    Spacer()
                    Image(systemName: store.isPro ? "chevron.right" : "lock.fill")
                        .font(Tokens.TextStyle.subheadline)
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
                        .font(Tokens.TextStyle.subheadlineSemibold)
                        .foregroundStyle(Tokens.Palette.textPrimary)
                    Spacer()
                    Text("\(health.thisWeekTotal.stepsFormatted) steps")
                        .font(Tokens.TextStyle.subheadline)
                        .foregroundStyle(Tokens.Palette.textTertiary)
                }
                if health.weekDays.isEmpty {
                    Text("No steps yet this week.")
                        .font(Tokens.TextStyle.subheadline)
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
                                .font(Tokens.TextStyle.headline)
                                .foregroundStyle(Tokens.Palette.textPrimary)
                            Text("Your best is \(max(streak, health.longestStreak(goal: goal))) days.")
                                .font(Tokens.TextStyle.subheadline)
                                .foregroundStyle(Tokens.Palette.textSecondary)
                        }
                    }
                }
            }
        }
        .animation(reduceMotion ? nil : .spring(response: 0.45, dampingFraction: 0.7), value: goalReached)
    }

    private func publishToWidget() {
        SharedStore.save(steps: health.todaySteps, goal: goal,
                         week: health.recentDays(7).map(\.steps))
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
                    .font(Tokens.TextStyle.title)
                    .foregroundStyle(Tokens.Palette.textPrimary)
                Text("Walkful reads your steps to show today's progress. Your data never leaves your device — we have no servers.")
                    .font(Tokens.TextStyle.subheadline)
                    .foregroundStyle(Tokens.Palette.textSecondary)
                PrimaryButton(title: "Continue") {
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
                    .font(Tokens.TextStyle.title)
                    .foregroundStyle(Tokens.Palette.textPrimary)
                Text(message)
                    .font(Tokens.TextStyle.subheadline)
                    .foregroundStyle(Tokens.Palette.textSecondary)
            }
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 0) {
                Text("Today")
                    .font(Tokens.TextStyle.title)
                    .foregroundStyle(Tokens.Palette.textPrimary)
                Text(Date.now.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated)))
                    .font(Tokens.TextStyle.caption)
                    .foregroundStyle(Tokens.Palette.textTertiary)
            }
            Spacer()
        }
        .padding(.horizontal, Tokens.Spacing.lg)
        .padding(.vertical, Tokens.Spacing.md)
        .background(.ultraThinMaterial)
    }
}
