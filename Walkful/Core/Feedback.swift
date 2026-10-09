import Foundation

/// The "Send feedback" mail in Settings (#182). Walkful collects no usage data,
/// so what people choose to write is how the app learns what's wrong. Everything
/// filled in here sits in the draft for the user to read before sending; nothing
/// leaves the phone unless they send it.
enum Feedback {
    static let address = "support@iamjarl.com"

    /// The marketing version alone, as in "1.1.4".
    static var marketingVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
    }

    /// Version and build, as in "1.1.4 (16)".
    static var appVersion: String {
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?"
        return "\(marketingVersion) (\(build))"
    }

    /// "26.0.1", read from ProcessInfo so it needs no main actor.
    static var systemVersion: String {
        let v = ProcessInfo.processInfo.operatingSystemVersion
        return v.patchVersion > 0 ? "\(v.majorVersion).\(v.minorVersion).\(v.patchVersion)"
                                  : "\(v.majorVersion).\(v.minorVersion)"
    }

    /// `mailto:` with the subject `Walkful 1.1.4 feedback` and a body that leaves
    /// room to write above the app and iOS versions.
    static func mailURL(marketingVersion: String = Self.marketingVersion,
                        appVersion: String = Self.appVersion,
                        systemVersion: String = Self.systemVersion) -> URL {
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = address
        components.queryItems = [
            URLQueryItem(name: "subject", value: "Walkful \(marketingVersion) feedback"),
            URLQueryItem(name: "body", value: "\n\n\n---\nWalkful \(appVersion)\niOS \(systemVersion)\n"),
        ]
        return components.url ?? URL(string: "mailto:\(address)")!
    }
}
