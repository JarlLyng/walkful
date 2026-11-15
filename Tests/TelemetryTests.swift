import XCTest
@testable import Walkful

/// #222: anonymous telemetry. Nothing here touches Sentry itself; these are the
/// rules that keep every report free of IDs and of anything from Apple Health.
final class TelemetryTests: XCTestCase {

    func testTheScreenCountCarriesOnlyFixedValues() {
        XCTAssertEqual(Telemetry.Screen.allCases.map(\.rawValue),
                       ["today", "insights", "settings", "coach", "paywall"])
    }

    func testMetricAttributesAllowNoUserOrIDs() {
        let allowed = Telemetry.allowedMetricAttributes
        XCTAssertTrue(allowed.contains("screen"))
        XCTAssertFalse(allowed.contains { $0.hasPrefix("user.") })
        XCTAssertFalse(allowed.contains { $0.contains("id") && !$0.hasPrefix("sentry.") })
        XCTAssertFalse(allowed.contains("span_id"))
    }

    func testTheContextLosesTheVendorHashAndDeviceID() {
        let context: [String: [String: Any]] = [
            "app": ["device_app_hash": "abc123", "app_version": "1.1.5"],
            "device": ["id": "xyz", "model": "iPhone17,1"],
        ]
        let anonymized = Telemetry.anonymizedContext(context)
        XCTAssertNil(anonymized["app"]?["device_app_hash"])
        XCTAssertNil(anonymized["device"]?["id"])
        XCTAssertEqual(anonymized["app"]?["app_version"] as? String, "1.1.5")
        XCTAssertEqual(anonymized["device"]?["model"] as? String, "iPhone17,1")
    }

    /// A binary's full path names the install's container, so only its file name goes.
    func testBinaryPathsKeepOnlyTheFileName() {
        let path = "/private/var/containers/Bundle/Application/4D3F1C2B-0000-4000-8000-000000000000/Walkful.app/Walkful"
        XCTAssertEqual(Telemetry.fileName(path), "Walkful")
        XCTAssertEqual(Telemetry.fileName("/usr/lib/system/libsystem_kernel.dylib"), "libsystem_kernel.dylib")
    }

    func testTheInstallationIDIsPinnedToTheSharedUser() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: dir) }
        let file = dir.appendingPathComponent("INSTALLATION")

        // A fresh install: no folder and no file yet.
        Telemetry.pinInstallationID(cacheDirectoryPath: dir.path)
        XCTAssertEqual(try String(contentsOf: file, encoding: .utf8), "anonymous")

        // An existing install: the SDK's random ID is replaced.
        try Data(UUID().uuidString.utf8).write(to: file)
        Telemetry.pinInstallationID(cacheDirectoryPath: dir.path)
        XCTAssertEqual(try String(contentsOf: file, encoding: .utf8), "anonymous")
    }
}
