import SwiftUI
import SwiftData

@main
struct WalkfulApp: App {
    init() {
        Telemetry.start()             // first, so a crash at launch is reported
        SedentaryMonitor.register()   // must register before launch completes
    }

    var body: some Scene {
        WindowGroup {
            RootContainer()
        }
        .modelContainer(for: AppSettings.self)
    }
}
