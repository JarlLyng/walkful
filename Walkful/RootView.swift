import SwiftUI
import SwiftData

/// Sikrer at der findes ét AppSettings-objekt og ruter til onboarding eller app.
struct RootContainer: View {
    @Environment(\.modelContext) private var context
    @Query private var settingsList: [AppSettings]
    @State private var health = HealthKitService()
    @State private var store = Store()

    var body: some View {
        Group {
            if let settings = settingsList.first {
                if settings.hasOnboarded {
                    RootView(settings: settings, health: health, store: store)
                } else {
                    OnboardingView(settings: settings, health: health)
                }
            } else {
                Tokens.Palette.appBackground
                    .ignoresSafeArea()
                    .onAppear { context.insert(AppSettings()) }
            }
        }
        .tint(Tokens.Palette.primary)
        .task { await store.load() }
    }
}

struct RootView: View {
    var settings: AppSettings
    var health: HealthKitService
    var store: Store

    var body: some View {
        TabView {
            TodayView(settings: settings, health: health, store: store)
                .tabItem { Label("Today", systemImage: "figure.walk") }
            InsightsView(settings: settings, health: health, store: store)
                .tabItem { Label("Insights", systemImage: "chart.bar") }
            SettingsView(settings: settings, store: store)
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .task {
            // Hold planlagte nudges + sedentary-monitor i sync ved app-start.
            await NudgeScheduler.reschedule(enabled: settings.nudgesEnabled,
                                            startHour: settings.nudgeStartHour,
                                            endHour: settings.nudgeEndHour)
        }
    }
}
