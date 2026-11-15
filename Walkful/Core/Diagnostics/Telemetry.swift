import Foundation
import Sentry

/// Anonymous crash reports, diagnostics and two feature counts, sent to Sentry
/// (#222). Anonymous is a recipe, not Sentry's default: out of the box
/// sentry-cocoa sends a random installation ID as the user, as every session's
/// `did` and on every metric, and a hash of the vendor ID on every event.
/// Everything here exists so that no ID leaves the device.
///
/// Walkful reads Apple Health, so one more rule binds this file: nothing read
/// from HealthKit, or derived from it (steps, distance, goals, streaks, dates),
/// goes into any event, breadcrumb, tag, attribute or count. The counts carry a
/// fixed value from a list, never a value from the user's data, and automatic
/// breadcrumbs are off so no on-screen text can ride along with a crash.
enum Telemetry {
    /// The one user every install reports as.
    static let anonymousUser = "anonymous"

    /// The screens a `screen.opened` count may name. Fixed values only.
    enum Screen: String, CaseIterable {
        case today, insights, settings, coach, paywall
    }

    /// The only attributes a metric may carry: the SDK's coarse facts (version,
    /// OS, device model) plus our own `screen`. Anything else, `user.id` included,
    /// is dropped in `beforeSendMetric`.
    static let allowedMetricAttributes: Set<String> = [
        "sentry.sdk.name", "sentry.sdk.version", "sentry.environment", "sentry.release",
        "os.name", "os.version", "device.brand", "device.model", "device.family",
        "screen",
    ]

    /// Starts Sentry if the build has a DSN. Not under XCTest, and not in the
    /// screenshot mode, where it would only send test noise.
    static func start() {
        let env = ProcessInfo.processInfo.environment
        if env["XCTestConfigurationFilePath"] != nil || env["XCTestSessionIdentifier"] != nil { return }
        if LaunchArgs.screenshots { return }

        // An environment variable wins, for pointing a debug run at a local
        // stand-in for Sentry (docs/SENTRY.md); otherwise the build's DSN.
        let dsn = (env["SENTRY_DSN"] ?? Bundle.main.object(forInfoDictionaryKey: "SentryDSN") as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !dsn.isEmpty else {
            #if DEBUG
            print("[Telemetry] No Sentry DSN, so nothing is sent. See docs/SENTRY.md.")
            #endif
            return
        }

        let options = Options()
        options.dsn = dsn
        options.environment = environment
        options.sendDefaultPii = false
        // Nothing that watches: no screenshot (Today shows the day's steps), no
        // view hierarchy, no session replay, and no automatic breadcrumbs, which
        // can carry a control's on-screen text.
        options.attachScreenshot = false
        options.attachViewHierarchy = false
        options.enableAutoBreadcrumbTracking = false
        options.enableNetworkBreadcrumbs = false
        options.enableCaptureFailedRequests = false
        // Crashes, hangs, crash-free sessions and MetricKit diagnostics, not
        // performance traces.
        options.tracesSampleRate = 0
        options.enableAutoSessionTracking = true
        options.enableMetricKit = true
        options.beforeSend = { anonymize($0) }
        options.beforeSendMetric = { anonymize($0) }

        // Sessions can't be given a user: sentry-cocoa takes every session's
        // `did` from the INSTALLATION file in its cache directory, and writes a
        // random UUID there when it's missing. Writing the shared user into the
        // file first makes every install report the same `did`. Checked against
        // the outgoing session envelope; check again after every SDK upgrade.
        pinInstallationID(cacheDirectoryPath: options.cacheDirectoryPath)

        SentrySDK.start(options: options)
        // Before any event or metric, so nothing falls back to an installation ID.
        SentrySDK.setUser(User(userId: anonymousUser))

        #if DEBUG
        // The envelope check, after every SDK upgrade (docs/SENTRY.md): one test
        // event and both counts, to read what actually leaves the phone.
        if ProcessInfo.processInfo.arguments.contains("-telemetryCheck") {
            SentrySDK.capture(message: "Walkful telemetry check")
            screenOpened(.today)
            remindersTurnedOn()
        }
        #endif
    }

    // MARK: - Feature counts

    /// A main screen came on screen.
    static func screenOpened(_ screen: Screen) {
        guard SentrySDK.isEnabled else { return }
        SentrySDK.metrics.count("screen.opened", value: 1, options: SentryMetricOptions(attributes: ["screen": screen.rawValue]))
    }

    /// The user turned move reminders on. No hours, no other setting.
    static func remindersTurnedOn() {
        guard SentrySDK.isEnabled else { return }
        SentrySDK.metrics.count("reminders.turned_on", value: 1, options: SentryMetricOptions())
    }

    // MARK: - Anonymizing

    /// `production` only for App Store builds, so simulator, debug and TestFlight
    /// runs aren't read as real crashes. TestFlight installs carry a sandbox receipt.
    static var environment: String {
        #if targetEnvironment(simulator)
        return "simulator"
        #elseif DEBUG
        return "debug"
        #else
        return (LegacyReceipt.self as ReceiptLocating.Type).url?.lastPathComponent == "sandboxReceipt" ? "testflight" : "production"
        #endif
    }

    /// Errors, crashes, hangs and MetricKit diagnostics: one shared user, no
    /// device or vendor-ID hash, and binary paths cut to their file name, since a
    /// full path names the install's container.
    static func anonymize(_ event: Event) -> Event {
        event.user = User(userId: anonymousUser)
        if let context = event.context {
            event.context = anonymizedContext(context)
        }
        event.debugMeta?.forEach { image in
            image.codeFile = image.codeFile.map(fileName)
        }
        for thread in event.threads ?? [] {
            thread.stacktrace?.frames.forEach { $0.package = $0.package.map(fileName) }
        }
        for exception in event.exceptions ?? [] {
            exception.stacktrace?.frames.forEach { $0.package = $0.package.map(fileName) }
        }
        return event
    }

    static func anonymize(_ metric: SentryMetric) -> SentryMetric {
        var metric = metric
        metric.attributes = metric.attributes.filter { allowedMetricAttributes.contains($0.key) }
        return metric
    }

    /// The contexts without `app.device_app_hash` and `device.id`.
    static func anonymizedContext(_ context: [String: [String: Any]]) -> [String: [String: Any]] {
        var context = context
        context["app"]?.removeValue(forKey: "device_app_hash")
        context["device"]?.removeValue(forKey: "id")
        return context
    }

    /// "/private/var/containers/Bundle/Application/<UUID>/Walkful.app/Walkful" → "Walkful".
    static func fileName(_ path: String) -> String {
        (path as NSString).lastPathComponent
    }

    static func pinInstallationID(cacheDirectoryPath: String) {
        let url = URL(fileURLWithPath: cacheDirectoryPath).appendingPathComponent("INSTALLATION")
        let pinned = Data(anonymousUser.utf8)
        guard (try? Data(contentsOf: url)) != pinned else { return }
        try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try? pinned.write(to: url, options: .atomic)
    }
}

// `appStoreReceiptURL` is deprecated since iOS 18 in favour of AppTransaction,
// which is async, and Sentry's environment has to be known when it starts, before
// a crash at launch. Reading it through a protocol keeps the call warning-free.
private protocol ReceiptLocating { static var url: URL? { get } }
private enum LegacyReceipt: ReceiptLocating {
    @available(iOS, deprecated: 18.0)
    static var url: URL? { Bundle.main.appStoreReceiptURL }
}
