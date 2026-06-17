# Changelog

All notable changes to Walkful are documented here. Format based on
[Keep a Changelog](https://keepachangelog.com/); this project uses semantic-ish versioning.

## [Unreleased]

### Added
- **Smarter, sedentary-aware nudges** — a background check (BackgroundTasks + HealthKit) fires a gentle reminder only when you've actually been still, within a user-set active-hours window, rate-limited to ~once per 2h. Quiet-hours pickers added to Settings (#2).
- **Interval-walking coach** — a guided session alternating easy/brisk phases with haptic cues and a configurable number of rounds, launched from Today. On-device, grounded in Bente Klarlund Pedersen's advice (#1).
- Today **dashboard**: progress ring with an evidence-based "meaning" line, stat chips (distance, active minutes, floors, week average), this-week bars, and a streak card.
- **Insights** tab: consistency heatmap, best time of day, resting heart rate, brisk-minute 4-week trend, lifetime distance milestone.
- Marketing **website** (`website/`) with SEO + GEO (structured data, FAQ schema) and a privacy policy page.
- Developer docs: `README.md`, `ARCHITECTURE.md`, `CONTRIBUTING.md`, this changelog.

### Changed
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

[Unreleased]: https://github.com/JarlLyng/walkful/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/JarlLyng/walkful/releases/tag/v0.1.0
