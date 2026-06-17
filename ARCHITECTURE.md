# Architecture

Walkful is a small, single-target SwiftUI app with **no backend**. Privacy is an architectural property: there is no network layer, no accounts, and no database beyond on-device storage.

## Principles

1. **On-device only** — health data is read from HealthKit and used in memory / on-device; nothing is transmitted.
2. **Tokens, not hardcoded values** — all colors/spacing/radius/typography come from `Tokens` (backed by the IAMJARL design system). Views never hardcode a hex or a pixel value, and everything supports light + dark.
3. **Meaning over vanity metrics** — features must help the user move more, not maximize screen time.
4. **English UI strings**, Danish allowed in code comments/product docs.

## App flow

```
WalkfulApp (@main)
  └─ .modelContainer(for: AppSettings.self)        // SwiftData
     └─ RootContainer                               // ensures one AppSettings row
        ├─ OnboardingView   (if !hasOnboarded)      // welcome → connect → goal → nudges
        └─ RootView         (if hasOnboarded)        // TabView: Today / Insights / Settings
```

- `WalkfulApp.init()` starts `MetricsSubscriber` (MetricKit).
- `RootContainer` owns the single `HealthKitService` instance and injects it into both onboarding and the tabs, so the authorization granted during onboarding is shared app-wide.

## Modules

| Path | Responsibility |
|------|----------------|
| `Core/Health/HealthKitService.swift` | `@MainActor @Observable` service. Read-only HealthKit access (steps, distance, flights, active minutes, resting HR). Today's totals, weekly history, insights (consistency, best time of day, lifetime distance, streaks). Live updates via `HKObserverQuery`. |
| `Core/Persistence/AppSettings.swift` | SwiftData `@Model` singleton: `dailyGoal`, `nudgesEnabled`, `hasOnboarded`. |
| `Core/Notifications/NudgeScheduler.swift` | Local `UserNotifications` only. Schedules/cancels gentle movement reminders based on `nudgesEnabled`. |
| `Core/Diagnostics/MetricsSubscriber.swift` | MetricKit subscriber — crash/performance payloads delivered by the OS (no third-party SDK, no servers). |
| `Core/Theme/WalkfulTheme.swift` | `Tokens` facade over `IAMJARLDesignTokens`; builds light/dark-adaptive `Color`s. |
| `Core/Theme/Components.swift` | Reusable views: `Card`, `PrimaryButton`, `ProgressRing`, `StatChip`, `WeekBars`. |
| `Core/Formatters.swift` | `Int.stepsFormatted` (en_US grouping). |
| `Features/Onboarding` | 4-step onboarding; writes goal/nudges to `AppSettings`. |
| `Features/Today` | Dashboard: ring + meaning line, stat chips, this-week bars, streak. |
| `Features/Insights` | Consistency heatmap, best time / resting HR, brisk-minute trend, lifetime milestone. |
| `Features/Settings` | Goal stepper, nudge toggle, privacy note. |

## Data flow

```
Apple Health ──(read-only, granular consent)──▶ HealthKitService (@Observable)
                                                      │  publishes todaySteps, weekDays,
                                                      │  lifetimeDistanceKm, …
                                                      ▼
                                              SwiftUI views (Today / Insights)

AppSettings (@Model, @Bindable) ──▶ goal & prefs drive the ring, streaks, nudges
```

- Step data is **never copied** into our storage — we read live from HealthKit (the source of truth) and only derive values (records, averages) in memory.
- `AppSettings` is the only persisted state.

## Concurrency

- `HealthKitService` is `@MainActor` so its `@Observable` properties mutate on the main actor.
- HealthKit query callbacks run on arbitrary queues; we bridge them with `withCheckedContinuation`, which resumes back on the main actor.
- Pure helpers used inside those callbacks (e.g. `weekStart`) are marked `nonisolated` to avoid main-actor isolation warnings.

## Adding a new metric (recipe)

1. Add the `HKQuantityType`/`HKObjectType` to the `readTypes` set in `requestAuthorization()`.
2. Add an `@Observable` property + a query method on `HealthKitService` (reuse `sum(_:unit:from:)` or add an `HKStatisticsCollectionQuery`).
3. Surface it in a view using `Tokens` + an existing component (`StatChip`, `WeekBars`, `Card`).
4. Handle the empty/zero state gracefully (no Apple Watch → some metrics are absent).

## Build & generation

The `.xcodeproj` is generated from `project.yml` by XcodeGen and is git-ignored. Capabilities (HealthKit), Info.plist keys (usage strings, export-compliance), signing team, and the SPM dependency all live in `project.yml`.
