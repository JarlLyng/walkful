import Foundation

/// Maps a recent daily-step average onto the step/mortality dose-response curve
/// (Paluch et al., Lancet Public Health 2022). Deliberately hedged: these are
/// **associations** from observational research, not medical advice, and the
/// curve **flattens** past ~7,500–10,000 steps — more is not linearly better.
struct LongevityZone: Equatable {
    let title: String
    let detail: String
    /// 0…1 position along the curve, for the marker in the card.
    let position: Double

    static func forAverage(_ avg: Int) -> LongevityZone {
        let position = min(Double(max(0, avg)) / 10_000, 1)
        switch avg {
        case ..<4_000:
            return LongevityZone(
                title: "Building a base",
                detail: "Every step above sedentary is associated with lower risk. Small, steady increases add up.",
                position: position)
        case 4_000..<7_000:
            return LongevityZone(
                title: "Benefits are kicking in",
                detail: "Around 5,000+ steps a day is associated with meaningfully lower all-cause mortality in large studies.",
                position: position)
        case 7_000..<10_000:
            return LongevityZone(
                title: "Strong-benefit zone",
                detail: "About 7,000 steps a day is associated with roughly 40–50% lower mortality risk versus very low activity, in large observational studies.",
                position: position)
        default:
            return LongevityZone(
                title: "Near the plateau",
                detail: "Past ~7,500–10,000 steps the curve flattens — extra steps add little further mortality benefit, though they're perfectly fine.",
                position: position)
        }
    }
}
