import SwiftUI

struct SettingsView: View {
    @Bindable var settings: AppSettings
    var store: Store

    @State private var showingPaywall = false

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
                Text("Every step counts. We suggest ~7,000 — not 10,000, which is a myth.")
                    .font(Tokens.TextStyle.caption)
                    .foregroundStyle(Tokens.Palette.textTertiary)
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

            Section("Privacy") {
                Label("All data stays on your device", systemImage: "lock.fill")
                    .font(Tokens.TextStyle.subheadline)
                    .foregroundStyle(Tokens.Palette.textSecondary)
            }
        }
        .tint(Tokens.Palette.primary)
        .sheet(isPresented: $showingPaywall) { PaywallView(store: store) }
    }
}
