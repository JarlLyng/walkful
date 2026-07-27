import SwiftUI
import UIKit

/// A shareable image of the user's own progress (#117).
///
/// Rendered on-device with `ImageRenderer` and handed to the system share
/// sheet, so nothing leaves the device unless the user sends it somewhere.
/// Deliberately fixed colours (see `Tokens.Gradient.export*`): an
/// `ImageRenderer` has no dependable light/dark trait, and a shared image
/// should look the same for everyone.
///
/// Tone rules: state what happened, never imply the user owes the app
/// anything. No "don't break your streak", no pressure.
struct ShareCardView: View {

    let steps: Int
    let goal: Int
    /// This week's daily totals, oldest→newest.
    let week: [Int]
    let streak: Int
    /// A year of daily totals for the grid, or empty to leave it out.
    let year: [Int]

    /// 4:5 with the year grid (the friendliest aspect for Instagram, Messages
    /// and Facebook), square without it — otherwise the free card is mostly
    /// empty space.
    private var cardSize: CGSize {
        CGSize(width: 360, height: year.isEmpty ? 360 : 450)
    }

    private var progress: Double {
        goal > 0 ? min(Double(steps) / Double(goal), 1) : 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(steps.stepsFormatted)
                    .font(.system(size: 56, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                Text("steps")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
            }

            ZStack(alignment: .leading) {
                Capsule().fill(.white.opacity(0.12)).frame(height: 8)
                Capsule()
                    .fill(Tokens.Gradient.exportBars)
                    .frame(width: (cardSize.width - 56) * progress, height: 8)
            }

            Text(progress >= 1 ? "Goal reached" : "of \(goal.stepsFormatted)")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.7))

            if !week.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("THIS WEEK")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.45))
                        .tracking(1)
                    HStack(alignment: .bottom, spacing: 6) {
                        let scale = max(week.max() ?? 0, goal)
                        ForEach(Array(week.enumerated()), id: \.offset) { _, value in
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Tokens.Gradient.exportBars)
                                .frame(height: max(4, 54 * CGFloat(value) / CGFloat(max(scale, 1))))
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .frame(height: 54, alignment: .bottom)
                }
            }

            if !year.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(year.filter { $0 >= goal }.count) DAYS AT GOAL THIS YEAR")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.45))
                        .tracking(1)
                    // One column per week, seven rows: the truer shape of a year,
                    // and short enough to leave room for the wordmark below.
                    // Built as explicit columns rather than a LazyVGrid, which
                    // overflowed the padding at this cell count.
                    HStack(spacing: 1) {
                        ForEach(Array(weekChunks.enumerated()), id: \.offset) { _, chunk in
                            VStack(spacing: 1) {
                                ForEach(Array(chunk.enumerated()), id: \.offset) { _, value in
                                    RoundedRectangle(cornerRadius: 0.5)
                                        .fill(cellColor(value))
                                        .aspectRatio(1, contentMode: .fit)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
            }

            Spacer(minLength: 0)

            HStack(spacing: 6) {
                if streak > 0 {
                    Text("\(streak)-day streak")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                }
                Spacer()
                Text("Walkful")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.75))
            }
        }
        .padding(28)
        .frame(width: cardSize.width, height: cardSize.height, alignment: .topLeading)
        .background(Tokens.Gradient.exportBackdrop)
    }

    /// `year` split into weeks of seven, oldest first.
    private var weekChunks: [[Int]] {
        stride(from: 0, to: year.count, by: 7).map {
            Array(year[$0..<min($0 + 7, year.count)])
        }
    }

    private func cellColor(_ steps: Int) -> Color {
        if steps >= goal { return Color(rgb: 0xD0FF00) }
        if steps >= goal / 2 { return Color(rgb: 0xD0FF00).opacity(0.35) }
        return .white.opacity(0.09)
    }
}

// MARK: - Presentation helpers

/// Wraps the rendered file so it can drive `.sheet(item:)`.
struct ShareItem: Identifiable {
    let id = UUID()
    let url: URL
}

/// The system share sheet. Used instead of `ShareLink` because the image is
/// rendered on tap — `ShareLink` would need it built on every layout pass.
struct ShareSheet: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }

    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {}
}

// MARK: - Rendering

extension ShareCardView {
    /// Renders the card to a PNG in the temporary directory. Returns nil if
    /// rendering fails.
    @MainActor
    func renderedItem() -> ShareItem? {
        let renderer = ImageRenderer(content: self)
        renderer.scale = 3 // 1080×1350
        guard let image = renderer.uiImage, let data = image.pngData() else { return nil }
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("walkful-progress.png")
        do {
            try data.write(to: url)
            return ShareItem(url: url)
        } catch {
            return nil
        }
    }
}
