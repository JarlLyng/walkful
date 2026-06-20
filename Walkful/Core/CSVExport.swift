import Foundation

/// Builds a CSV of the user's own derived step data, on-device. "Your data,
/// your export" — nothing leaves the phone except via the share sheet the user
/// chooses.
enum CSVExport {

    /// `Date,Steps` with one row per day (oldest→newest), ISO dates.
    static func dailySteps(_ days: [HealthKitService.DayStat]) -> String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "en_US_POSIX")
        fmt.dateFormat = "yyyy-MM-dd"
        var lines = ["Date,Steps"]
        for day in days.sorted(by: { $0.date < $1.date }) {
            lines.append("\(fmt.string(from: day.date)),\(day.steps)")
        }
        return lines.joined(separator: "\n")
    }

    /// Writes CSV text to a temp file and returns its URL (for `ShareLink`).
    static func writeTempFile(_ csv: String, name: String = "walkful-steps.csv") -> URL? {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(name)
        do {
            try csv.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            return nil
        }
    }
}
