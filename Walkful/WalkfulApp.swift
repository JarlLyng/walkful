import SwiftUI
import SwiftData

@main
struct WalkfulApp: App {
    init() {
        MetricsSubscriber.shared.start()
    }

    var body: some Scene {
        WindowGroup {
            RootContainer()
        }
        .modelContainer(for: AppSettings.self)
    }
}
