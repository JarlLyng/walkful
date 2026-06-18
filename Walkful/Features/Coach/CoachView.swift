import SwiftUI

struct CoachView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var coach = IntervalCoach()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: Tokens.Spacing.xxl) {
            if coach.isFinished {
                finished
            } else if coach.hasStarted {
                active
            } else {
                intro
            }
        }
        .padding(Tokens.Spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(Tokens.Palette.appBackground)
        .onReceive(timer) { _ in coach.tick() }
    }

    // MARK: - Intro

    private var intro: some View {
        VStack(alignment: .leading, spacing: Tokens.Spacing.lg) {
            Spacer()
            Image(systemName: "figure.walk.motion")
                .font(.system(size: 40))
                .foregroundStyle(Tokens.Palette.primary)
            Text("Interval walk")
                .font(Tokens.TextStyle.bigTitle)
                .foregroundStyle(Tokens.Palette.textPrimary)
            Text("Alternate easy and brisk walking. A few brisk intervals can meaningfully boost your fitness — no running, no lycra required.")
                .font(Tokens.TextStyle.body)
                .foregroundStyle(Tokens.Palette.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Stepper(value: $coach.rounds, in: 2...8) {
                Text("\(coach.rounds) rounds · 3 min easy / 3 min brisk")
                    .font(Tokens.TextStyle.subheadline)
                    .foregroundStyle(Tokens.Palette.textPrimary)
            }
            .tint(Tokens.Palette.primary)

            Text("About \(coach.briskMinutes) brisk minutes total.")
                .font(Tokens.TextStyle.caption)
                .foregroundStyle(Tokens.Palette.textTertiary)

            Spacer()
            PrimaryButton(title: "Start") { coach.start() }
            Button("Not now") { dismiss() }
                .font(Tokens.TextStyle.subheadline)
                .foregroundStyle(Tokens.Palette.textSecondary)
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Active

    private var active: some View {
        VStack(spacing: Tokens.Spacing.xl) {
            Text("Round \(coach.currentRound) of \(coach.rounds)")
                .font(Tokens.TextStyle.subheadline)
                .foregroundStyle(Tokens.Palette.textTertiary)

            Text(coach.phase.title)
                .font(Tokens.TextStyle.bigTitle)
                .foregroundStyle(coach.phase == .brisk ? Tokens.Palette.accentText : Tokens.Palette.textSecondary)

            ZStack {
                ProgressRing(progress: coach.phaseProgress)
                    .frame(width: 220, height: 220)
                Text(mmss(coach.remaining))
                    .font(.system(size: 48, weight: .semibold))
                    .monospacedDigit()
                    .foregroundStyle(Tokens.Palette.textPrimary)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(coach.phase.title) phase, \(coach.remaining) seconds left, round \(coach.currentRound) of \(coach.rounds)")

            HStack(spacing: Tokens.Spacing.md) {
                secondaryButton(coach.isRunning ? "Pause" : "Resume") { coach.togglePause() }
                secondaryButton("End") { coach.stop(); dismiss() }
            }
        }
    }

    // MARK: - Finished

    private var finished: some View {
        VStack(spacing: Tokens.Spacing.lg) {
            Spacer()
            Image(systemName: "checkmark.circle")
                .font(.system(size: 48))
                .foregroundStyle(Tokens.Palette.primary)
            Text("Nice walk!")
                .font(Tokens.TextStyle.bigTitle)
                .foregroundStyle(Tokens.Palette.textPrimary)
            Text("You completed \(coach.rounds) brisk intervals — about \(coach.briskMinutes) brisk minutes. Every step counts.")
                .font(Tokens.TextStyle.body)
                .foregroundStyle(Tokens.Palette.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
            PrimaryButton(title: "Done") { dismiss() }
        }
    }

    // MARK: - Helpers

    private func secondaryButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(Tokens.TextStyle.headline)
                .foregroundStyle(Tokens.Palette.textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Tokens.Spacing.md)
                .overlay(
                    RoundedRectangle(cornerRadius: Tokens.Radius.md)
                        .stroke(Tokens.Palette.borderDefault, lineWidth: 0.5)
                )
        }
    }

    private func mmss(_ s: Int) -> String {
        String(format: "%d:%02d", s / 60, s % 60)
    }
}

#Preview {
    CoachView()
}
