# CLAUDE.md — Walkful

Quick-start context for developers and AI assistants. Detailed specs in `docs/`.

## What is Walkful?

Walkful is a calm, private step & walking tracker for iPhone. It reads your
activity from Apple Health and turns it into meaningful daily progress and
insights, grounded in walking science (~7,000 steps, not the 10,000 myth).
Everything is processed and stored **on the device** — no accounts, no servers,
no ads, no data collection. Its App Store privacy label is "Data Not Collected".

- **Developer:** Jarl Lyng / [IAMJARL](https://iamjarl.com)
- **Website:** [walkful.iamjarl.com](https://walkful.iamjarl.com)
- **License:** [AGPL-3.0](LICENSE) — open source.
- **Price:** Free download with a one-time **Walkful Pro** unlock (StoreKit 2 non-consumable). No subscription, no ads.
- **Status:** Live on the App Store — id `6781303837`, v1.0.1.
- **Sister apps:** part of the [IAMJARL](https://iamjarl.com) portfolio.

## Strategy lives in the private hub

Target audience, positioning, pricing reasoning, SEO/ASO playbooks, launch/marketing
plans and competitor analysis are **not** in this public repo — they're in the private
[iamjarl-strategy](https://github.com/JarlLyng/iamjarl-strategy) hub (folder `Walkful/`).
Before doing any audience / positioning / pricing / marketing work, read that repo's
`CONVENTIONS.md` and write results there, not here. Keep this public repo to code, the
marketing **site** source (`website/`), and normal OSS docs.

## App features (be precise — do not invent features that don't exist)

- **Today:** progress ring with an evidence-based "meaning" line, distance, active minutes, floors, this-week bars, week average, and a streak card.
- **Insights (Pro):** week/month/year step trends, a full-year consistency heatmap, mobility & fitness (walking speed, steadiness, VO₂max, resting HR), records gallery, monthly recap, and a longevity-zone card.
- **Interval-walking coach (Pro):** guided easy/brisk sessions with haptics.
- **Widgets:** Home Screen (`systemSmall`, `systemMedium` "This week") + Lock Screen accessory families.
- **Gentle nudges:** sedentary-aware local reminders within a user-set active-hours window.
- **CSV export (Pro), Rate/Share, and a once-per-day App Store review prompt.**

### Features that do NOT exist (common hallucination targets)
- No accounts, login, servers, backend, or cloud sync — all on-device.
- No ads, no subscription, no third-party analytics/tracking SDKs (crash/perf via Apple **MetricKit** only, on-device).
- No social features, leaderboards, friends or challenges (you compete with your own records).
- **No standalone Apple Watch app or complication yet** — Watch data flows in via Apple Health, but there is no Watch target.
- No Android, no GPS route/map tracking, no calorie/diet tracking.
- No in-app Danish localization yet (the app UI is English; the marketing site has a `/da/` page).

## Requirements
- iOS 18+. Xcode 26+, [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`).

## Build & run
- `project.yml` is the **source of truth**; `Walkful.xcodeproj` is generated and git-ignored.
- `xcodegen generate` then open `Walkful.xcodeproj`, or:
  `xcodebuild -project Walkful.xcodeproj -scheme Walkful -destination 'generic/platform=iOS Simulator' build`
- Tests: the `WalkfulTests` target (run via the `Walkful` scheme).
- **Versioning:** bump `MARKETING_VERSION` / `CURRENT_PROJECT_VERSION` in `project.yml`, then `xcodegen generate` — the managed Info.plist reads them via `$(...)`. Don't edit versions in Xcode's UI.
- **CI/CD:** GitHub Actions (`.github/workflows/ci.yml`) builds + tests every PR to `main`. **Xcode Cloud** builds/archives from the **`release`** branch — push `main` → `release` to trigger a build. Because the `.xcodeproj` is generated, `ci_scripts/ci_post_clone.sh` runs `xcodegen generate` after Xcode Cloud clones.

## Conventions
- Design tokens come from the `IAMJARLDesignTokens` SPM package (Aurora layer on top). No hardcoded colors/spacing/radius/type.
- Privacy-first by architecture: HealthKit is **read-only**; nothing leaves the device. Keep the "Data Not Collected" posture.
- SwiftUI + SwiftData + HealthKit + StoreKit 2 + WidgetKit + BackgroundTasks. iOS 18 minimum.
