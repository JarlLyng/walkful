import XCTest
import Foundation
@testable import Walkful

/// Guards the localization itself (#40). These catch the failure mode that is
/// easy to miss: a string that compiles and looks fine in English but was never
/// translated, so a Danish user silently gets English.
final class LocalizationTests: XCTestCase {

    private let bundle = Bundle(for: HealthKitService.self)

    func testDanishIsBundled() {
        XCTAssertTrue(bundle.localizations.contains("da"),
                      "da.lproj missing from the app bundle — the String Catalog didn't compile a Danish table")
    }

    /// Every key in the compiled Danish table must differ from its English
    /// value, unless it is deliberately identical (brand names, symbols, words
    /// Danish borrows unchanged).
    func testDanishTableTranslatesWhatItShould() throws {
        let identical: Set<String> = [
            "Walkful", "WALKFUL", "Walkful Pro", "OK", "Insights",
            "distance", "Distance", "Pause", "Miles", "min",
        ]
        let daURL = try XCTUnwrap(bundle.url(forResource: "Localizable", withExtension: "strings",
                                             subdirectory: "da.lproj"),
                                  "no Danish Localizable.strings in the bundle")
        let enURL = try XCTUnwrap(bundle.url(forResource: "Localizable", withExtension: "strings",
                                             subdirectory: "en.lproj"))
        let da = try XCTUnwrap(NSDictionary(contentsOf: daURL) as? [String: String])
        let en = try XCTUnwrap(NSDictionary(contentsOf: enURL) as? [String: String])

        XCTAssertGreaterThan(da.count, 100, "suspiciously few Danish strings")

        var untranslated: [String] = []
        for (key, daValue) in da {
            guard let enValue = en[key] else { continue }
            // A value that still equals the English one, and isn't just a format
            // string or an intentional passthrough, means a missed translation.
            let isFormatOnly = daValue.replacingOccurrences(of: "%@", with: "")
                .replacingOccurrences(of: "%lld", with: "")
                .trimmingCharacters(in: CharacterSet.alphanumerics.inverted).isEmpty
            if daValue == enValue, !identical.contains(daValue), !isFormatOnly {
                untranslated.append(key)
            }
        }
        XCTAssertTrue(untranslated.isEmpty,
                      "these strings are still English in the Danish table: \(untranslated.sorted())")
    }

    /// The Danish plural table has to exist, or "%lld-dages stime" would read
    /// wrong at a one-day streak.
    func testDanishPluralsAreBundled() throws {
        let url = try XCTUnwrap(bundle.url(forResource: "Localizable", withExtension: "stringsdict",
                                           subdirectory: "da.lproj"),
                                "no Danish stringsdict — plural variations were dropped")
        let dict = try XCTUnwrap(NSDictionary(contentsOf: url) as? [String: Any])
        XCTAssertFalse(dict.isEmpty)
    }
}
