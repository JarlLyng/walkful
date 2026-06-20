import XCTest
@testable import Walkful

@MainActor
final class CSVExportTests: XCTestCase {

    private let cal = Calendar(identifier: .iso8601)

    private func date(_ y: Int, _ m: Int, _ d: Int) -> Date {
        cal.date(from: DateComponents(year: y, month: m, day: d))!
    }

    func testDailyStepsSortsAscendingWithHeader() {
        // Input out of order → output oldest→newest, ISO dates.
        let csv = CSVExport.dailySteps([
            .init(date: date(2026, 1, 2), steps: 8_000),
            .init(date: date(2026, 1, 1), steps: 5_000),
        ])
        XCTAssertEqual(csv, "Date,Steps\n2026-01-01,5000\n2026-01-02,8000")
    }

    func testEmptyHistoryIsHeaderOnly() {
        XCTAssertEqual(CSVExport.dailySteps([]), "Date,Steps")
    }
}
