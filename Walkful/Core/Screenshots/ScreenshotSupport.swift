import Foundation

/// Launch-argument helpers for capturing App Store screenshots with sample data.
/// `-screenshots` enables sample mode; `-screen <today|insights|settings|coach|paywall>`
/// picks the starting screen. The sample-data injection itself is DEBUG-only (see
/// HealthKitService.loadSampleData / Store.forcePro), so release builds are
/// unaffected even if the flag were somehow passed.
enum LaunchArgs {
    static var screenshots: Bool {
        ProcessInfo.processInfo.arguments.contains("-screenshots")
    }

    /// `-screen paywall` opens Insights with sample data but *without* forcing
    /// Pro, so the locked state (its blurred preview) can be captured/verified.
    static var lockedPreview: Bool {
        screenshots && screen == "paywall"
    }

    /// `-site` with `-screenshots`: captures for the marketing site (walkful#200).
    /// The site's rule is no streaks, so the sample day sits under the goal with
    /// no streak behind it, and Today's ring fills once, for the hero's loop.
    static var site: Bool {
        screenshots && ProcessInfo.processInfo.arguments.contains("-site")
    }

    static var screen: String {
        let args = ProcessInfo.processInfo.arguments
        if let i = args.firstIndex(of: "-screen"), i + 1 < args.count {
            return args[i + 1]
        }
        return "today"
    }
}
