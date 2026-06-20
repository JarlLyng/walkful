import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Lette haptiske tilbagemeldinger. Kun on-device; no-op hvor UIKit mangler.
enum Haptics {
    static func success() {
        #if canImport(UIKit)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        #endif
    }

    static func impact() {
        #if canImport(UIKit)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        #endif
    }
}
