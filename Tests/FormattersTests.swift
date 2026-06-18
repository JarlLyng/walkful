import XCTest
@testable import Walkful

final class FormattersTests: XCTestCase {

    func testStepsFormattedGroupsWithCommas() {
        XCTAssertEqual(0.stepsFormatted, "0")
        XCTAssertEqual(1_000.stepsFormatted, "1,000")
        XCTAssertEqual(7_000.stepsFormatted, "7,000")
        XCTAssertEqual(1_234_567.stepsFormatted, "1,234,567")
    }
}
