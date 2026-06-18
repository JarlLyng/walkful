import SwiftUI

// Genbrugelige UI-byggeklodser bygget på IAMJARL-tokens + Aurora-laget.

// MARK: - Glass card modifier

extension View {
    /// Frosted "glass" surface used across cards (Aurora).
    func glassCard(padding: CGFloat = Tokens.Spacing.lg) -> some View {
        self
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Tokens.Radius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: Tokens.Radius.lg)
                    .stroke(Tokens.Palette.borderSubtle, lineWidth: 0.5)
            )
    }
}

// MARK: - Card

struct Card<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content.glassCard()
    }
}

// MARK: - TrendChart (gradient bars + average line)

struct TrendChartView: View {
    var values: [Int]
    var height: CGFloat = 96

    private var scaleMax: Int { max(values.max() ?? 1, 1) }
    private var average: Int { values.isEmpty ? 0 : values.reduce(0, +) / values.count }

    var body: some View {
        HStack(alignment: .bottom, spacing: 3) {
            ForEach(Array(values.enumerated()), id: \.offset) { _, v in
                RoundedRectangle(cornerRadius: 3)
                    .fill(Tokens.Gradient.bars)
                    .frame(height: max(3, height * CGFloat(v) / CGFloat(scaleMax)))
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(height: height, alignment: .bottom)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Tokens.Palette.accentText.opacity(0.55))
                .frame(height: 1)
                .padding(.bottom, height * CGFloat(average) / CGFloat(scaleMax))
        }
        .accessibilityHidden(true) // decorative; the caption conveys the values
    }
}

// MARK: - PrimaryButton

struct PrimaryButton: View {
    var title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Tokens.TextStyle.headline)
                .foregroundStyle(Tokens.Palette.onPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Tokens.Spacing.md)
                .background(Tokens.Gradient.ring, in: RoundedRectangle(cornerRadius: Tokens.Radius.md))
        }
    }
}

// MARK: - ProgressRing (gradient + glow)

struct ProgressRing: View {
    /// 0...1
    var progress: Double
    var lineWidth: CGFloat = 12

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Circle()
                .stroke(Tokens.Palette.ringTrack, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: max(0, min(progress, 1)))
                .stroke(
                    Tokens.Gradient.ring,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: Tokens.Palette.primary.opacity(0.45), radius: 8)
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.5), value: progress)
        }
    }
}

// MARK: - StatChip (glass)

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
                    .font(Tokens.TextStyle.statNumber)
                    .foregroundStyle(fg)
                if let unit {
                    Text(unit)
                        .font(Tokens.TextStyle.caption)
                        .foregroundStyle(accent ? Tokens.Palette.accentText : Tokens.Palette.textTertiary)
                }
            }
            Text(label)
                .font(Tokens.TextStyle.caption)
                .foregroundStyle(accent ? Tokens.Palette.accentText : Tokens.Palette.textTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Tokens.Spacing.md)
        .background {
            if accent {
                Tokens.Palette.primary.opacity(0.12)
            } else {
                Rectangle().fill(.ultraThinMaterial)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: Tokens.Radius.md)
                .stroke(Tokens.Palette.borderSubtle, lineWidth: 0.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: Tokens.Radius.md))
        .accessibilityElement(children: .combine)
    }
}

// MARK: - WeekBars (gradient)

struct WeekBars: View {
    var values: [Int]
    var scaleMax: Int
    var height: CGFloat = 56

    var body: some View {
        HStack(alignment: .bottom, spacing: Tokens.Spacing.sm) {
            ForEach(Array(values.enumerated()), id: \.offset) { _, v in
                RoundedRectangle(cornerRadius: Tokens.Radius.sm)
                    .fill(Tokens.Gradient.bars)
                    .frame(height: max(4, height * CGFloat(v) / CGFloat(max(scaleMax, 1))))
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(height: height, alignment: .bottom)
        .accessibilityHidden(true) // decorative; totals are shown as text
    }
}
