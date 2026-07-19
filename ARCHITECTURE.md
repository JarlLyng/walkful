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
| `Core/Health/HealthKitService.swift` | `@MainActor @Observable` service. Read-only HealthKit access (steps, distance, flights, active minutes, resting HR, walking speed/steadiness, VO₂max). Today's totals, ~1 year of daily history, monthly totals, trends, records (best day/week/month, streaks, most floors), best time of day, lifetime distance. Live updates via `HKObserverQuery`. |
| `Core/Persistence/AppSettings.swift` | SwiftData `@Model` singleton: `dailyGoal`, `nudgesEnabled`, `hasOnboarded`, `nudgeStartHour`/`nudgeEndHour` (active-hours window), `useImperial` (km/mi), `adaptiveGoal` + `lastGoalAdjustmentDay` (at most one auto-adjust per day, never overriding a same-day manual change), `lastGoalCelebrationDay` (goal haptic once/day), `hasRequestedReview` (review prompt once ever). **New properties need inline defaults** or existing installs crash on migration. |
| `Core/Notifications/NudgeScheduler.swift` | Local `UserNotifications`. Notification permission + keeps `SedentaryMonitor`'s mirrored settings in sync; clears pre-1.0.4 clock-based reminders. All nudges come from the sedentary monitor — nothing fires on a fixed clock (#113). |
| `Core/Notifications/SedentaryMonitor.swift` | `BackgroundTasks` (`BGAppRefreshTask`) + HealthKit. The smart layer: nudges only when actually sedentary, in-window, rate-limited (~2h). |
| `Core/Store/Store.swift` | StoreKit 2 (`@MainActor @Observable`). One-time "Walkful Pro" unlock; `isPro` from `Transaction.currentEntitlements`; `purchase()`/`restore()` + updates listener; `purchaseError` surfaces failed/unverified/pending purchases to the paywall. |
| `Core/CSVExport.swift` | Builds the step-history CSV for the Pro export in Settings (share sheet). |
| `Core/Haptics.swift` | Small haptics helpers (goal celebration, coach phase changes). |
| `Core/Shared/SharedStore.swift` | Writes today's snapshot (steps + goal) to the App Group (`group.com.iamjarl.walkful`) for the widget. Compiled into both the app and the widget. |
| `Core/Diagnostics/MetricsSubscriber.swift` | MetricKit subscriber — crash/performance payloads delivered by the OS (no third-party SDK, no servers). |
| `Core/Theme/WalkfulTheme.swift` | `Tokens` facade over `IAMJARLDesignTokens`; light/dark-adaptive `Color`s, the **Aurora** layer (`Tokens.Gradient.ring/bars/heroBackdrop`), and scalable `Tokens.TextStyle.*` (Dynamic Type). |
| `Core/Theme/Components.swift` | Reusable views: `Card`/`.glassCard()`, `PrimaryButton`, `ProgressRing` (gradient + glow, respects Reduce Motion), `StatChip`, `WeekBars`, `TrendChartView`. |
| `Core/Screenshots/ScreenshotSupport.swift` | `LaunchArgs` — `-screenshots`/`-screen` flags for DEBUG sample-data captures. |
| `Core/Formatters.swift` | `Int.stepsFormatted` (en_US grouping). Also compiled into the widget. |
| `Features/Onboarding` | 4-step onboarding; writes goal/nudges to `AppSettings`. |
| `Features/Today` | Dashboard: ring + meaning line, stat chips, this-week bars, streak, interval-coach CTA. Publishes the widget snapshot. Coach is **Pro-gated** (→ paywall). |
| `Features/Insights` | **Pro-gated.** Week/month/year trends + year heatmap, best time / longest streak, mobility & fitness (walking speed/steadiness/VO₂max/resting HR), longevity-zone card, brisk-minute trend, records gallery, monthly recap, lifetime milestone. Two-phase load behind a skeleton: the screen appears as soon as history is ready; heavier metrics fill in after. |
| `Features/Coach` | `IntervalCoach` (model) + `CoachView` — guided easy/brisk interval walk with haptics. |
| `Features/Paywall` | `PaywallView` — calm one-time-unlock paywall + restore. |
| `Features/Settings` | Goal stepper + adaptive-goal toggle, units (km/mi), nudge toggle + active-hours window, Walkful Pro section, CSV export (Pro), Rate & Share, privacy note. |
| `WalkfulWidget/` | WidgetKit extension — `systemSmall` Steps + `systemMedium` "This week" + Lock Screen accessory families. Reads the App Group snapshot via `SharedStore`; a stale (pre-midnight) snapshot renders as 0, and the timeline resets itself at midnight. |

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

## Visual design (Aurora)

A premium layer **derived from** the IAMJARL tokens, not hardcoded one-offs:
- `Tokens.Gradient.ring` / `.bars` / `.heroBackdrop` — adaptive gradients (light purple→pink, dark lime→teal→blue) built from the brand colors.
- `ProgressRing` strokes with the gradient + a soft glow; `Card`/`StatChip` use `.glassCard()` (`.ultraThinMaterial`); charts fill with the gradient; Today/Insights sit on the aurora backdrop.
- Keep new UI on these — don't reintroduce flat solid fills or hardcoded hex.

## Accessibility

- **Dynamic Type:** use `Tokens.TextStyle.*` (scalable) for all text — never fixed `.system(size:)`. Verified at `accessibility-extra-large`.
- **VoiceOver:** decorative charts (week/trend bars, year heatmap) are `accessibilityHidden` because their values exist as text; the progress ring carries a label + value; stat chips combine into single elements.
- **Reduce Motion:** `ProgressRing` disables its animation when the setting is on.
- App Store Accessibility labels declared: VoiceOver, Larger Text, Reduced Motion, Dark Interface, Sufficient Contrast.

## Screenshots

A DEBUG-only screenshot mode (`-screenshots [-screen today|insights|settings]`) injects sample data (`HealthKitService.loadSampleData`) and unlocks Pro (`Store.forcePro`); guards skip live HealthKit loads and the notification prompt. Capture on an iPhone 16 Pro Max sim (1320×2868) — see [CONTRIBUTING.md](CONTRIBUTING.md).

## Build & generation

The `.xcodeproj` is generated from `project.yml` by XcodeGen and is git-ignored, along with the generated `Walkful/Info.plist` and `WalkfulWidget/Info.plist`. Two targets: the **app** and the **`WalkfulWidget`** extension (embedded). Capabilities (HealthKit, App Groups), Info.plist keys (usage strings, export-compliance, `BGTaskSchedulerPermittedIdentifiers`, `UIBackgroundModes`, widget `NSExtension`), signing team, the SPM dependency, and the run scheme's StoreKit config all live in `project.yml`. Because `BGTaskSchedulerPermittedIdentifiers` has no `INFOPLIST_KEY_` build setting, both targets use a **managed Info.plist** (`GENERATE_INFOPLIST_FILE: NO`).
