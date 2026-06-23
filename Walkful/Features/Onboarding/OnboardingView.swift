import SwiftUI

struct OnboardingView: View {
    @Bindable var settings: AppSettings
    var health: HealthKitService
    @State private var step = 0

    private let icons = ["figure.walk", "heart.text.square", "target", "bell.badge"]

    var body: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.xl) {
            progressDots

            VStack(alignment: .leading, spacing: Tokens.Spacing.lg) {
                Image(systemName: icons[min(step, icons.count - 1)])
                    .font(.system(size: 44))
                    .foregroundStyle(Tokens.Gradient.ring)
                    .accessibilityHidden(true)
                content
            }
            .id(step)
            .transition(.opacity)

            Spacer()

            PrimaryButton(title: buttonTitle, action: primaryAction)
        }
        .padding(Tokens.Spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Tokens.Gradient.heroBackdrop.ignoresSafeArea())
        .animation(.easeInOut(duration: 0.3), value: step)
    }

    private var progressDots: some View {
        HStack(spacing: Tokens.Spacing.sm) {
            ForEach(0..<4, id: \.self) { i in
                Capsule()
                    .fill(i == step ? AnyShapeStyle(Tokens.Gradient.ring)
                                    : AnyShapeStyle(Tokens.Palette.borderDefault))
                    .frame(width: i == step ? 24 : 7, height: 7)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Step \(step + 1) of 4")
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
                        .font(Tokens.TextStyle.titleNumber)
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
                    .font(Tokens.TextStyle.body)
                    .foregroundStyle(Tokens.Palette.textPrimary)
            }
        }
    }

    private func textBlock(_ title: String, _ body: String) -> some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.md) {
            Text(title)
                .font(Tokens.TextStyle.bigTitle)
                .foregroundStyle(Tokens.Palette.textPrimary)
            Text(body)
                .font(Tokens.TextStyle.body)
                .foregroundStyle(Tokens.Palette.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var buttonTitle: String {
        switch step {
        case 0: "Get started"
        case 1: "Continue"
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
