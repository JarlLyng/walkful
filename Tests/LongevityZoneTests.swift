import XCTest
@testable import Walkful

final class LongevityZoneTests: XCTestCase {

    func testBaseZoneBelow4k() {
        let z = LongevityZone.forAverage(2_000)
        XCTAssertEqual(z.title, "Building a base")
        XCTAssertEqual(z.position, 0.2, accuracy: 0.001)
    }

    func testBenefitsZone() {
        XCTAssertEqual(LongevityZone.forAverage(5_000).title, "Benefits are kicking in")
    }

    func testStrongBenefitZone() {
        let z = LongevityZone.forAverage(7_000)
        XCTAssertEqual(z.title, "Strong-benefit zone")
        XCTAssertEqual(z.position, 0.7, accuracy: 0.001)
    }

    func testPlateauZoneCapsPositionAtOne() {
        let z = LongevityZone.forAverage(15_000)
        XCTAssertEqual(z.title, "Near the plateau")
        XCTAssertEqual(z.position, 1.0, accuracy: 0.001)
    }

    func testZeroIsBaseZoneAtStart() {
        let z = LongevityZone.forAverage(0)
        XCTAssertEqual(z.title, "Building a base")
        XCTAssertEqual(z.position, 0.0, accuracy: 0.001)
    }
}
