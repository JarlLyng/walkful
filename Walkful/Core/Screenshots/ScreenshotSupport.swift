import Foundation

/// Launch-argument helpers for capturing App Store screenshots with sample data.
/// `-screenshots` enables sample mode; `-screen <today|insights|settings>` picks
/// the starting tab. The sample-data injection itself is DEBUG-only (see
/// HealthKitService.loadSampleData / Store.forcePro), so release builds are
/// unaffected even if the flag were somehow passed.
enum LaunchArgs {
    static var screenshots: Bool {
        ProcessInfo.processInfo.arguments.contains("-screenshots")
    }

    static var screen: String {
        let args = ProcessInfo.processInfo.arguments
        if let i = args.firstIndex(of: "-screen"), i + 1 < args.count {
            return args[i + 1]
        }
        return "today"
    }
}
