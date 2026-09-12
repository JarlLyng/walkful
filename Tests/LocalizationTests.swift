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
            "distance", "Distance", "Pause", "Miles", "min", "Start",
        ]
        let daURL = try XCTUnwrap(bundle.url(forResource: "Localizable", withExtension: "strings",
                                             subdirectory: "da.lproj"),
                                  "no Danish Localizable.strings in the bundle")
        let da = try XCTUnwrap(NSDictionary(contentsOf: daURL) as? [String: String])

        // A dropped translation is invisible to the loop below: the compiled
        // table simply omits that key, and iterating the table never looks at
        // it. This floor is the tripwire for that. Raise it when you add
        // strings; if it fails after an edit that added none, a translation
        // was orphaned, most likely by rewriting an English string, which
        // renames its key.
        XCTAssertGreaterThanOrEqual(da.count, 161,
                                    "Danish strings went missing: a rewritten English string renames its key, and the translation has to move with it")

        // The key IS the English source string, because the catalog's
        // sourceLanguage is en. Comparing against en.lproj instead looks
        // reasonable and checks nothing: that table holds a single entry,
        // since English resolves from the key and is never emitted.
        var untranslated: [String] = []
        for (key, daValue) in da {
            // A value that still equals its English key, and isn't just a format
            // string or an intentional passthrough, means a missed translation.
            let isFormatOnly = daValue.replacingOccurrences(of: "%@", with: "")
                .replacingOccurrences(of: "%lld", with: "")
                .trimmingCharacters(in: CharacterSet.alphanumerics.inverted).isEmpty
            if daValue == key, !identical.contains(daValue), !isFormatOnly {
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
