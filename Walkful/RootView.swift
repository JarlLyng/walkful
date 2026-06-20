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
                if settings.hasOnboarded || LaunchArgs.screenshots {
                    RootView(settings: settings, health: health, store: store)
                } else {
                    OnboardingView(settings: settings, health: health)
                }
            } else {
                Tokens.Palette.appBackground
                    .ignoresSafeArea()
                    .onAppear {
                        let s = AppSettings()
                        if LaunchArgs.screenshots { s.hasOnboarded = true }
                        context.insert(s)
                    }
            }
        }
        .tint(Tokens.Palette.primary)
        .task {
            #if DEBUG
            if LaunchArgs.screenshots {
                health.loadSampleData()
                store.forcePro()
                return
            }
            #endif
            await store.load()
        }
    }
}

struct RootView: View {
    var settings: AppSettings
    var health: HealthKitService
    var store: Store

    @State private var tab: Tab = .today

    enum Tab: Hashable { case today, insights, settings }

    var body: some View {
        TabView(selection: $tab) {
            TodayView(settings: settings, health: health, store: store)
                .tag(Tab.today)
                .tabItem { Label("Today", systemImage: "figure.walk") }
            InsightsView(settings: settings, health: health, store: store)
                .tag(Tab.insights)
                .tabItem { Label("Insights", systemImage: "chart.bar") }
            SettingsView(settings: settings, health: health, store: store)
                .tag(Tab.settings)
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
        .onAppear {
            if LaunchArgs.screenshots {
                switch LaunchArgs.screen {
                case "insights": tab = .insights
                case "settings": tab = .settings
                default: tab = .today
                }
            }
        }
        .task {
            if LaunchArgs.screenshots { return }
            // Genetabler HealthKit-adgang ved cold launch. authState er ikke
            // persisteret, og read-auth kan ikke aflæses — så et nyt kald er
            // idempotent: iOS viser ikke systemarket igen hvis adgang allerede
            // er givet, men authState bliver .authorized og dashboardet vises.
            if health.authState == .unknown { await health.requestAuthorization() }
            // Hold planlagte nudges + sedentary-monitor i sync ved app-start.
            await NudgeScheduler.reschedule(enabled: settings.nudgesEnabled,
                                            startHour: settings.nudgeStartHour,
                                            endHour: settings.nudgeEndHour)
        }
    }
}
