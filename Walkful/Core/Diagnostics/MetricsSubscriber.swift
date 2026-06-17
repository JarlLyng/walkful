import Foundation
import MetricKit
import os

/// Privacy-ren crash-/performance-indsigt via Apples MetricKit.
/// Rapporter leveres af OS'et (synlige i Xcode Organizer) under brugerens
/// eksisterende "del med udviklere"-samtykke — ingen tredjeparts-SDK,
/// ingen egne servere. Bevarer App Store-labelen "Data Not Collected".
final class MetricsSubscriber: NSObject, MXMetricManagerSubscriber {

    static let shared = MetricsSubscriber()

    private let log = Logger(subsystem: "com.iamjarl.walkful", category: "metrics")

    func start() {
        MXMetricManager.shared.add(self)
    }

    func didReceive(_ payloads: [MXMetricPayload]) {
        for payload in payloads {
            log.info("Received metric payload (\(payload.dictionaryRepresentation().count) keys).")
        }
    }

    func didReceive(_ payloads: [MXDiagnosticPayload]) {
        for payload in payloads {
            let crashes = payload.crashDiagnostics?.count ?? 0
            let hangs = payload.hangDiagnostics?.count ?? 0
            log.error("Received diagnostic payload — crashes: \(crashes), hangs: \(hangs).")
        }
    }
}
