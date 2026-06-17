import SwiftUI

// Genbrugelige UI-byggeklodser bygget på IAMJARL-tokens.

// MARK: - Card

struct Card<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(Tokens.Spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Tokens.Palette.appBackground)
            .overlay(
                RoundedRectangle(cornerRadius: Tokens.Radius.lg)
                    .stroke(Tokens.Palette.borderSubtle, lineWidth: 0.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.lg))
    }
}

// MARK: - PrimaryButton

struct PrimaryButton: View {
    var title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: Tokens.FontSize.base, weight: .semibold))
                .foregroundStyle(Tokens.Palette.onPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Tokens.Spacing.md)
                .background(Tokens.Palette.primary)
                .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.md))
        }
    }
}

// MARK: - ProgressRing

struct ProgressRing: View {
    /// 0...1
    var progress: Double
    var lineWidth: CGFloat = 12

    var body: some View {
        ZStack {
            Circle()
                .stroke(Tokens.Palette.ringTrack, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: max(0, min(progress, 1)))
                .stroke(
                    Tokens.Palette.primary,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.4), value: progress)
        }
    }
}

// MARK: - StatChip (dashboard)

struct StatChip: View {
    var value: String
    var unit: String?
    var label: String
    var accent: Bool = false

    private var fg: Color { accent ? Tokens.Palette.accentText : Tokens.Palette.textPrimary }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text(value)
                    .font(.system(size: Tokens.FontSize.lg, weight: .semibold))
                    .foregroundStyle(fg)
                if let unit {
                    Text(unit)
                        .font(.system(size: Tokens.FontSize.xs))
                        .foregroundStyle(accent ? Tokens.Palette.accentText : Tokens.Palette.textTertiary)
                }
            }
            Text(label)
                .font(.system(size: Tokens.FontSize.xs))
                .foregroundStyle(accent ? Tokens.Palette.accentText : Tokens.Palette.textTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Tokens.Spacing.md)
        .background(accent ? Tokens.Palette.primary.opacity(0.10) : Tokens.Palette.mutedFill)
        .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.md))
    }
}

// MARK: - WeekBars

struct WeekBars: View {
    var values: [Int]
    var scaleMax: Int
    var height: CGFloat = 56

    var body: some View {
        HStack(alignment: .bottom, spacing: Tokens.Spacing.sm) {
            ForEach(Array(values.enumerated()), id: \.offset) { _, v in
                RoundedRectangle(cornerRadius: Tokens.Radius.sm)
                    .fill(Tokens.Palette.primary)
                    .frame(height: max(4, height * CGFloat(v) / CGFloat(max(scaleMax, 1))))
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(height: height, alignment: .bottom)
    }
}
