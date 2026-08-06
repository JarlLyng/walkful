import XCTest
@testable import Walkful

final class FormattersTests: XCTestCase {

    /// Grouping follows the reader's locale since the app was localized (#40),
    /// so this asserts that grouping happens with the locale's own separator
    /// rather than hard-coding the English comma.
    func testStepsFormattedGroupsForCurrentLocale() {
        let sep = Locale.current.groupingSeparator ?? ","
        XCTAssertEqual(0.stepsFormatted, "0")
        XCTAssertEqual(1_000.stepsFormatted, "1\(sep)000")
        XCTAssertEqual(7_000.stepsFormatted, "7\(sep)000")
        XCTAssertEqual(1_234_567.stepsFormatted, "1\(sep)234\(sep)567")
    }
}
