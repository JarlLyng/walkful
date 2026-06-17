import SwiftUI

struct SettingsView: View {
    @Bindable var settings: AppSettings

    var body: some View {
        Form {
            Section("Daily goal") {
                Stepper(value: $settings.dailyGoal, in: 1_000...30_000, step: 500) {
                    Text("\(settings.dailyGoal.stepsFormatted) steps")
                        .foregroundStyle(Tokens.Palette.textPrimary)
                }
                Text("Every step counts. We suggest ~7,000 — not 10,000, which is a myth.")
                    .font(.system(size: Tokens.FontSize.xs))
                    .foregroundStyle(Tokens.Palette.textTertiary)
            }

            Section("Nudges") {
                Toggle("Move reminders", isOn: $settings.nudgesEnabled)
                    .onChange(of: settings.nudgesEnabled) { _, enabled in
                        Task { await NudgeScheduler.reschedule(enabled: enabled) }
                    }
            }

            Section("Privacy") {
                Label("All data stays on your device", systemImage: "lock.fill")
                    .font(.system(size: Tokens.FontSize.sm))
                    .foregroundStyle(Tokens.Palette.textSecondary)
            }
        }
        .tint(Tokens.Palette.primary)
    }
}
