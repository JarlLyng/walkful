import SwiftUI
import SwiftData

/// Sikrer at der findes ét AppSettings-objekt og ruter til onboarding eller app.
struct RootContainer: View {
    @Environment(\.modelContext) private var context
    @Query private var settingsList: [AppSettings]
    @State private var health = HealthKitService()

    var body: some View {
        Group {
            if let settings = settingsList.first {
                if settings.hasOnboarded {
                    RootView(settings: settings, health: health)
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
    }
}

struct RootView: View {
    var settings: AppSettings
    var health: HealthKitService

    var body: some View {
        TabView {
            TodayView(settings: settings, health: health)
                .tabItem { Label("Today", systemImage: "figure.walk") }
            InsightsView(settings: settings, health: health)
                .tabItem { Label("Insights", systemImage: "chart.bar") }
            SettingsView(settings: settings)
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .task {
            // Hold planlagte nudges i sync med brugerens valg ved app-start.
            await NudgeScheduler.reschedule(enabled: settings.nudgesEnabled)
        }
    }
}
