import XCTest
@testable import Walkful

/// #182: the feedback mail opens with the right address, subject and versions.
final class FeedbackTests: XCTestCase {

    func testTheMailGoesToSupportWithTheVersionsFilledIn() throws {
        let url = Feedback.mailURL(marketingVersion: "1.1.4", appVersion: "1.1.4 (16)", systemVersion: "26.0")
        XCTAssertEqual(url.scheme, "mailto")

        let components = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: false))
        XCTAssertEqual(components.path, "support@iamjarl.com")
        let items = Dictionary(uniqueKeysWithValues: (components.queryItems ?? []).map { ($0.name, $0.value ?? "") })
        XCTAssertEqual(items["subject"], "Walkful 1.1.4 feedback")
        XCTAssertEqual(items["body"], "\n\n\n---\nWalkful 1.1.4 (16)\niOS 26.0\n")
    }

    /// Spaces and line breaks must be percent-encoded, or Mail drops the body.
    func testTheURLIsFullyEncoded() {
        let url = Feedback.mailURL(marketingVersion: "1.1.4", appVersion: "1.1.4 (16)", systemVersion: "26.0")
        XCTAssertFalse(url.absoluteString.contains(" "))
        XCTAssertFalse(url.absoluteString.contains("\n"))
        XCTAssertTrue(url.absoluteString.hasPrefix("mailto:support@iamjarl.com?subject=Walkful%201.1.4%20feedback"))
    }
}
