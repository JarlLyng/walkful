import SwiftUI

struct SettingsView: View {
    @Bindable var settings: AppSettings
    var health: HealthKitService
    var store: Store

    @State private var showingPaywall = false
    @State private var exportURL: URL?
    @State private var preparingExport = false

    private func resync() {
        let enabled = settings.nudgesEnabled
        let start = settings.nudgeStartHour
        let end = settings.nudgeEndHour
        Task { await NudgeScheduler.reschedule(enabled: enabled, startHour: start, endHour: end) }
    }

    private func hourLabel(_ h: Int) -> String { String(format: "%02d:00", h) }

    var body: some View {
        Form {
            Section("Daily goal") {
                Stepper(value: $settings.dailyGoal, in: 1_000...30_000, step: 500) {
                    Text("\(settings.dailyGoal.stepsFormatted) steps")
                        .foregroundStyle(Tokens.Palette.textPrimary)
                }
                .onChange(of: settings.dailyGoal) { _, _ in
                    // A manual change claims today's slot so adaptive goal won't
                    // override it the moment you return to Today.
                    settings.lastGoalAdjustmentDay = .now
                }
                Toggle("Adaptive goal", isOn: $settings.adaptiveGoal)
                Text(settings.adaptiveGoal
                     ? "Your goal rises in small steps as your recent average grows — never down. Adjust it any time."
                     : "Every step counts. We suggest ~7,000 — not 10,000, which is a myth.")
                    .font(Tokens.TextStyle.caption)
                    .foregroundStyle(Tokens.Palette.textTertiary)
            }

            Section("Units") {
                Picker("Distance", selection: $settings.useImperial) {
                    Text("Kilometres").tag(false)
                    Text("Miles").tag(true)
                }
            }

            Section("Nudges") {
                Toggle("Move reminders", isOn: $settings.nudgesEnabled)
                    .onChange(of: settings.nudgesEnabled) { _, _ in resync() }

                if settings.nudgesEnabled {
                    Picker("From", selection: $settings.nudgeStartHour) {
                        ForEach(5..<13) { Text(hourLabel($0)).tag($0) }
                    }
                    .onChange(of: settings.nudgeStartHour) { _, _ in resync() }
                    Picker("Until", selection: $settings.nudgeEndHour) {
                        ForEach(15..<24) { Text(hourLabel($0)).tag($0) }
                    }
                    .onChange(of: settings.nudgeEndHour) { _, _ in resync() }
                    Text("Walkful only reminds you when you've actually been sitting a while, within these hours — at most a couple of times a day.")
                        .font(Tokens.TextStyle.caption)
                        .foregroundStyle(Tokens.Palette.textTertiary)
                }
            }

            Section("Walkful Pro") {
                if store.isPro {
                    Label("Pro unlocked — thank you!", systemImage: "checkmark.seal.fill")
                        .font(Tokens.TextStyle.subheadline)
                        .foregroundStyle(Tokens.Palette.textSecondary)
                } else {
                    Button("Unlock Walkful Pro") { showingPaywall = true }
                        .foregroundStyle(Tokens.Palette.primary)
                    Button("Restore purchase") { Task { await store.restore() } }
                        .foregroundStyle(Tokens.Palette.textSecondary)
                }
            }

            Section("Your data") {
                if store.isPro {
                    if let exportURL {
                        ShareLink(item: exportURL) {
                            Label("Export steps (CSV)", systemImage: "square.and.arrow.up")
                                .foregroundStyle(Tokens.Palette.primary)
                        }
                    } else {
                        HStack {
                            Label("Export steps (CSV)", systemImage: "square.and.arrow.up")
                                .foregroundStyle(Tokens.Palette.textTertiary)
                            Spacer()
                            if preparingExport { ProgressView() }
                        }
                    }
                } else {
                    Button {
                        showingPaywall = true
                    } label: {
                        HStack {
                            Label("Export steps (CSV)", systemImage: "square.and.arrow.up")
                                .foregroundStyle(Tokens.Palette.textPrimary)
                            Spacer()
                            Image(systemName: "lock.fill")
                                .foregroundStyle(Tokens.Palette.textTertiary)
                        }
                    }
                }
                Text("Your day-by-day step history as a CSV file — generated and shared on-device. Your data, your export.")
                    .font(Tokens.TextStyle.caption)
                    .foregroundStyle(Tokens.Palette.textTertiary)
            }

            Section("Enjoying Walkful?") {
                Link(destination: URL(string: "https://apps.apple.com/app/id6781303837?action=write-review")!) {
                    Label("Rate Walkful", systemImage: "star")
                        .foregroundStyle(Tokens.Palette.primary)
                }
                ShareLink(item: URL(string: "https://apps.apple.com/app/id6781303837")!,
                          subject: Text("Walkful"),
                          message: Text("A calm, private step tracker for iPhone — no ads, no subscription.")) {
                    Label("Share Walkful", systemImage: "square.and.arrow.up")
                        .foregroundStyle(Tokens.Palette.primary)
                }
            }

            Section("Privacy") {
                Label("All data stays on your device", systemImage: "lock.fill")
                    .font(Tokens.TextStyle.subheadline)
                    .foregroundStyle(Tokens.Palette.textSecondary)
            }
        }
        .tint(Tokens.Palette.primary)
        .sheet(isPresented: $showingPaywall) { PaywallView(store: store) }
        .task(id: store.isPro) { await prepareExport() }
    }

    /// Build the CSV file on-device so the ShareLink is ready instantly when tapped.
    private func prepareExport() async {
        guard store.isPro, exportURL == nil, !LaunchArgs.screenshots else { return }
        preparingExport = true
        defer { preparingExport = false }
        if health.recentDays(1).isEmpty { await health.loadHistory() }
        let csv = CSVExport.dailySteps(health.recentDays(400))
        exportURL = CSVExport.writeTempFile(csv)
    }
}
