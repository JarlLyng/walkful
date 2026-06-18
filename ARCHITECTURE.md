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

- `WalkfulApp.init()` starts `MetricsSubscriber` (MetricKit) and registers the `SedentaryMonitor` background task.
- `RootContainer` owns the single `HealthKitService` and `Store` instances and injects them into the tabs (and `HealthKitService` into onboarding), so authorization and Pro entitlement are shared app-wide. It calls `store.load()` on appear.

## Modules

| Path | Responsibility |
|------|----------------|
| `Core/Health/HealthKitService.swift` | `@MainActor @Observable` service. Read-only HealthKit access (steps, distance, flights, active minutes, resting HR). Today's totals, weekly history, insights (consistency, best time of day, lifetime distance, streaks). Live updates via `HKObserverQuery`. |
| `Core/Persistence/AppSettings.swift` | SwiftData `@Model` singleton: `dailyGoal`, `nudgesEnabled`, `hasOnboarded`, `nudgeStartHour`/`nudgeEndHour` (active-hours window). |
| `Core/Notifications/NudgeScheduler.swift` | Local `UserNotifications`. Baseline reminders clamped to the active-hours window; keeps `SedentaryMonitor`'s mirrored settings in sync. |
| `Core/Notifications/SedentaryMonitor.swift` | `BackgroundTasks` (`BGAppRefreshTask`) + HealthKit. The smart layer: nudges only when actually sedentary, in-window, rate-limited (~2h). |
| `Core/Store/Store.swift` | StoreKit 2 (`@MainActor @Observable`). One-time "Walkful Pro" unlock; `isPro` from `Transaction.currentEntitlements`; `purchase()`/`restore()` + updates listener. |
| `Core/Shared/SharedStore.swift` | Writes today's snapshot (steps + goal) to the App Group (`group.com.iamjarl.walkful`) for the widget. Compiled into both the app and the widget. |
| `Core/Diagnostics/MetricsSubscriber.swift` | MetricKit subscriber — crash/performance payloads delivered by the OS (no third-party SDK, no servers). |
| `Core/Theme/WalkfulTheme.swift` | `Tokens` facade over `IAMJARLDesignTokens`; builds light/dark-adaptive `Color`s. |
| `Core/Theme/Components.swift` | Reusable views: `Card`, `PrimaryButton`, `ProgressRing`, `StatChip`, `WeekBars`. |
| `Core/Formatters.swift` | `Int.stepsFormatted` (en_US grouping). Also compiled into the widget. |
| `Features/Onboarding` | 4-step onboarding; writes goal/nudges to `AppSettings`. |
| `Features/Today` | Dashboard: ring + meaning line, stat chips, this-week bars, streak, interval-coach CTA. Publishes the widget snapshot. Coach is **Pro-gated** (→ paywall). |
| `Features/Insights` | **Pro-gated.** Consistency heatmap, best time / resting HR, brisk-minute trend, lifetime milestone. |
| `Features/Coach` | `IntervalCoach` (model) + `CoachView` — guided easy/brisk interval walk with haptics. |
| `Features/Paywall` | `PaywallView` — calm one-time-unlock paywall + restore. |
| `Features/Settings` | Goal stepper, nudge toggle + active-hours window, Walkful Pro section, privacy note. |
| `WalkfulWidget/` | WidgetKit extension — `systemSmall` + Lock Screen accessory families. Reads the App Group snapshot via `SharedStore`. |

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

## Freemium & gating

- `Store.isPro` is the single source of truth. The **Today dashboard is free**; the **interval coach** and the **Insights tab** are gated. Locked entry points present `PaywallView`.
- Entitlement is checked on-device via StoreKit 2 (`Transaction.currentEntitlements`) — no server. A local `Walkful.storekit` config (wired into the run scheme) drives purchases in the simulator; the real IAP (`com.iamjarl.walkful.pro`) must exist in App Store Connect for TestFlight/production.

## Widget & App Group

The app writes a small `DailySnapshot` (steps + goal) to the shared App Group (`group.com.iamjarl.walkful`) via `SharedStore`, then calls `WidgetCenter.reloadAllTimelines()`. The widget reads that snapshot — it does **not** access HealthKit itself. `SharedStore` and `Formatters` are compiled into both targets.

## Build & generation

The `.xcodeproj` is generated from `project.yml` by XcodeGen and is git-ignored, along with the generated `Walkful/Info.plist` and `WalkfulWidget/Info.plist`. Two targets: the **app** and the **`WalkfulWidget`** extension (embedded). Capabilities (HealthKit, App Groups), Info.plist keys (usage strings, export-compliance, `BGTaskSchedulerPermittedIdentifiers`, `UIBackgroundModes`, widget `NSExtension`), signing team, the SPM dependency, and the run scheme's StoreKit config all live in `project.yml`. Because `BGTaskSchedulerPermittedIdentifiers` has no `INFOPLIST_KEY_` build setting, both targets use a **managed Info.plist** (`GENERATE_INFOPLIST_FILE: NO`).
