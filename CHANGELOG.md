# Changelog

All notable changes to Walkful are documented here. Format based on
[Keep a Changelog](https://keepachangelog.com/); this project uses semantic-ish versioning.

## [Unreleased]

### Fixed
- **Adaptive goal no longer overrides your manual goal.** With Adaptive goal on, opening Today re-ran the adjustment on every visit, so a goal you'd just set (e.g. 7,500) jumped up (to 8,000) and could keep climbing. It now adjusts at most once per day and never overrides a goal you changed yourself the same day (build 10).

### Added
- **App Store review prompt** — a single, well-timed request shown at a genuine high point (you just hit your goal *and* you're on a 3+ day streak), asked at most once ever and throttled by the system. No nagging, in keeping with the calm ethos.
- **Rate & Share in Settings** — a "Rate Walkful" link (opens the App Store review sheet) and a "Share Walkful" share button, for the people who want to spread the word.
- **Insights loading skeleton** — a calm placeholder while your insights load, instead of an empty flash. Loads fast: the screen appears as soon as your history is ready, and the heavier metrics (mobility, lifetime distance, etc.) fill in after (build 10).

### Changed
- **Open-sourced under AGPL-3.0.** Relicensed from proprietary ahead of making the repo public. Strategy/marketing docs (target audience, ASO, launch kit, competitor research) moved to a private hub; added a `CLAUDE.md`.
- **More compact Consistency heatmap** — the year grid is tighter and less dominant (build 10).
- **Refreshed app icon** (build 10).

## [1.0.0] — 2026-06-24 — 🎉 Released on the App Store (build 8)

First public release — [App Store ID 6781303837](https://apps.apple.com/app/id6781303837).

### Fixed
- **HealthKit permission flow (App Review 5.1.1).** The pre-permission message no longer uses a "Connect" button (now neutral "Continue") and no longer offers a "Not now" escape — the user always proceeds to the system permission request after the explanation. Affects onboarding and the Today connect card. Build 8.

### Added
- **Units & adaptive goal** — Settings now has a kilometres/miles toggle (distance shows in your unit across Today and Insights), and an opt-in adaptive daily goal that nudges your target up in small steps as your recent average grows — only ever upward (#43).
- **Delightful moments** — the progress ring eases up to its value, a "Goal reached today" pill springs in when you hit your goal, and a gentle success haptic fires once a day on goal completion. All respect Reduce Motion (#10).
- **"This week" widget** — a medium Home Screen widget with a 7-day bar chart (total + average per day, bars that hit your goal in full colour) and a rectangular Lock Screen variant. Reads the on-device App Group snapshot (#44).
- **Data export (CSV) — Pro** — Settings → Your data → "Export steps (CSV)" writes your day-by-day step history to a CSV and shares it via the system share sheet. Generated entirely on-device — your data, your export (#41).
- **Longevity zone card** — Insights maps your 7-day average onto the step/mortality dose-response curve (Lancet, 2022) with a position marker. Carefully hedged ("associations from observational research — not medical advice"), and honest that the curve flattens past ~7,500–10,000 steps (#42).

## [0.2.0] — 2026-06-20 — Pro v2, widgets, coach, nudges, Aurora & accessibility (build 7)

### Fixed
- **Apple Health re-prompt on every launch.** `authState` is in-memory and read authorization can't be queried back, so a cold launch always showed the "Connect Apple Health" card again instead of the dashboard. The app now re-establishes authorization on launch (idempotent — no system prompt if access is already granted), so the dashboard and data appear immediately. Build 7.
- **White screen on launch when upgrading from v0.1.** `AppSettings`' new properties lacked inline default values, so SwiftData's lightweight migration couldn't open an existing store. Added inline defaults to every property (a default in `init()` is not enough for migration). Build 3.

### Added
- **Insight → action** — Insights opens with a contextual card that turns a pattern into a next step: turn on reminders for your weakest weekday, keep an active streak alive, or plan around your best time of day (#6).
- **Accessibility** — full Dynamic Type (scalable text styles), VoiceOver support (decorative charts hidden, labelled ring, meaningful text equivalents), Reduced Motion, and verified contrast in light + dark (#9).
- **Pro: Records & monthly recap** — Insights now has a records gallery (best day, best week, best month, longest streak, most floors) and a calm monthly recap (this month's steps + change vs last month) (#23).
- **Pro: Mobility & fitness** — Insights now shows walking speed, walking steadiness, cardio fitness (VO₂max) and resting heart rate. Apple Watch-derived metrics hide gracefully when absent (#22).
- **Pro: Trends & history** — Insights now has week/month/year step trends with an average line, and a full-year consistency heatmap (replacing the 30-day grid). History extended to ~1 year (#21).
- **Walkful Pro** — a one-time (non-consumable) StoreKit 2 unlock for Insights and the interval-walking coach. Calm paywall, restore purchases, on-device entitlement check (no subscription, no server). Today and Insights stay free; the gated parts show a paywall. Includes a local `Walkful.storekit` config for testing (#5).
- **Home Screen & Lock Screen widgets** (WidgetKit) — a step-progress widget in `systemSmall` plus Lock Screen accessory families (circular, inline, rectangular). The app publishes today's snapshot to a shared App Group; the widget reads it. On-device (#3).
- **Smarter, sedentary-aware nudges** — a background check (BackgroundTasks + HealthKit) fires a gentle reminder only when you've actually been still, within a user-set active-hours window, rate-limited to ~once per 2h. Quiet-hours pickers added to Settings (#2).
- **Interval-walking coach** — a guided session alternating easy/brisk phases with haptic cues and a configurable number of rounds, launched from Today. On-device, grounded in Bente Klarlund Pedersen's advice (#1).
- Today **dashboard**: progress ring with an evidence-based "meaning" line, stat chips (distance, active minutes, floors, week average), this-week bars, and a streak card.
- **Insights** tab: consistency heatmap, best time of day, resting heart rate, brisk-minute 4-week trend, lifetime distance milestone.
- Marketing **website** (`website/`) with SEO + GEO (structured data, FAQ schema) and a privacy policy page.
- Developer docs: `README.md`, `ARCHITECTURE.md`, `CONTRIBUTING.md`, this changelog.

### Changed
- **Onboarding polish** — Aurora backdrop, a gradient progress indicator, a per-step icon, and a smooth fade between steps (#7).
- **Aurora visual refresh** — a premium layer over the IAMJARL tokens: gradient progress ring with a soft glow, frosted glass cards, gradient-filled trend/week bars, rounded numerals, and a subtle aurora backdrop on Today/Insights. Light = purple→pink, dark = lime→teal→blue (#30).
- Tabs are now **Today / Insights / Settings** (the standalone Week tab was folded into Today + Insights).
- Design tokens now come from the real `IAMJARLDesignTokens` SPM package (was a local copy).

## [0.1.0] — 2026-06-17 — first TestFlight build

### Added
- App skeleton with the IAMJARL theme (light/dark), tab navigation.
- HealthKit integration (read-only): today's steps/distance/floors, weekly history, live updates.
- Onboarding (welcome → connect Apple Health → goal → nudges) with goal persisted in SwiftData.
- Personal records: best week, current/longest streak ("compete with yourself").
- Local movement nudges (UserNotifications).
- Layered app icon (light/dark/tinted); MetricKit diagnostics; privacy "Data Not Collected".

[Unreleased]: https://github.com/JarlLyng/walkful/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/JarlLyng/walkful/compare/v0.2.0...v1.0.0
[0.2.0]: https://github.com/JarlLyng/walkful/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/JarlLyng/walkful/releases/tag/v0.1.0
