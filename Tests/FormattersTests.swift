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

    /// #195: the distance chip read "5.8 km" on a Danish phone. Pinned to
    /// explicit locales, since the simulator's own locale says nothing.
    func testOneDecimalUsesTheLocalesDecimalSeparator() {
        let da = Locale(identifier: "da_DK"), en = Locale(identifier: "en_US")
        XCTAssertEqual(5.8.oneDecimal(locale: da), "5,8")
        XCTAssertEqual(5.8.oneDecimal(locale: en), "5.8")
        XCTAssertEqual(5.99.oneDecimal(locale: da), "6,0")
        XCTAssertEqual(0.0.oneDecimal(locale: da), "0,0")
        XCTAssertEqual(1.36.oneDecimal(locale: en), "1.4")
    }
}
