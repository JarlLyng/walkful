import SwiftUI

struct OnboardingView: View {
    @Bindable var settings: AppSettings
    var health: HealthKitService
    @State private var step = 0

    var body: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.xl) {
            Text("Step \(step + 1) of 4")
                .font(.system(size: Tokens.FontSize.xs))
                .foregroundStyle(Tokens.Palette.primary)

            content

            Spacer()

            PrimaryButton(title: buttonTitle, action: primaryAction)

            if step == 1 {
                Button("Not now") { advance() }
                    .font(.system(size: Tokens.FontSize.sm))
                    .foregroundStyle(Tokens.Palette.textSecondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(Tokens.Spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Tokens.Palette.appBackground)
    }

    @ViewBuilder private var content: some View {
        switch step {
        case 0:
            textBlock(
                "Welcome to Walkful",
                "Every step counts. Walkful turns your walks into something meaningful — calmly, and entirely on your phone."
            )
        case 1:
            textBlock(
                "Connect Apple Health",
                "Walkful reads your steps, distance and stairs to show your progress. Your data never leaves your device — we have no servers."
            )
        case 2:
            VStack(alignment: .leading, spacing: Tokens.Spacing.xl) {
                textBlock(
                    "Set your daily goal",
                    "We suggest 7,000 — research links it to far lower mortality than 2,000. Not 10,000, which is a myth."
                )
                Stepper(value: $settings.dailyGoal, in: 1_000...30_000, step: 500) {
                    Text("\(settings.dailyGoal.stepsFormatted) steps")
                        .font(.system(size: Tokens.FontSize.xl, weight: .semibold))
                        .foregroundStyle(Tokens.Palette.textPrimary)
                }
            }
        default:
            VStack(alignment: .leading, spacing: Tokens.Spacing.xl) {
                textBlock(
                    "Gentle nudges",
                    "Walkful can remind you to break up long sitting with a short walk or the stairs — a couple of times a day at most. Fully optional."
                )
                Toggle("Move reminders", isOn: $settings.nudgesEnabled)
                    .tint(Tokens.Palette.primary)
                    .font(.system(size: Tokens.FontSize.base))
                    .foregroundStyle(Tokens.Palette.textPrimary)
            }
        }
    }

    private func textBlock(_ title: String, _ body: String) -> some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.md) {
            Text(title)
                .font(.system(size: Tokens.FontSize.xxl, weight: .semibold))
                .foregroundStyle(Tokens.Palette.textPrimary)
            Text(body)
                .font(.system(size: Tokens.FontSize.base))
                .foregroundStyle(Tokens.Palette.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var buttonTitle: String {
        switch step {
        case 0: "Get started"
        case 1: "Connect"
        case 2: "Continue"
        default: "Start walking"
        }
    }

    private func primaryAction() {
        if step == 1 {
            Task {
                await health.requestAuthorization()
                advance()
            }
        } else {
            advance()
        }
    }

    private func advance() {
        if step >= 3 {
            settings.hasOnboarded = true
            let enabled = settings.nudgesEnabled
            let startHour = settings.nudgeStartHour
            let endHour = settings.nudgeEndHour
            Task { await NudgeScheduler.reschedule(enabled: enabled, startHour: startHour, endHour: endHour) }
        } else {
            withAnimation { step += 1 }
        }
    }
}
