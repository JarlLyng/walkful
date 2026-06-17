import SwiftUI
import SwiftData

@main
struct WalkfulApp: App {
    init() {
        MetricsSubscriber.shared.start()
        SedentaryMonitor.register()   // must register before launch completes
    }

    var body: some Scene {
        WindowGroup {
            RootContainer()
        }
        .modelContainer(for: AppSettings.self)
    }
}
