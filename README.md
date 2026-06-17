# Walkful

> Every step counts.

A calm, private, evidence-based **step & walking tracker for iPhone and Apple Watch**. Walkful adds a meaningful motivation layer on top of Apple Health — and keeps **everything on your device**: no accounts, no servers, no ads, no data collection.

Made by **IAMJARL**.

---

## Status

- ✅ MVP complete and **shipped to TestFlight**, tested on device.
- 🚧 Now building toward a paid public launch (active-walking coach, widgets, Watch complication). See **[GitHub Issues](../../issues)** for the live backlog.

## What makes it different

- **Meaning over numbers** — progress is paired with what it means for your health, grounded in research (2025 Lancet Public Health; Bente Klarlund Pedersen), not the 10,000-steps myth.
- **Private by architecture** — all data is read from Apple Health and processed on-device. App Store privacy label: *Data Not Collected*.
- **Calm, no manipulation** — no pace-shaming, no social leaderboards, no dark patterns. You compete against your own records.

See **[RESEARCH.md](RESEARCH.md)** (market + science) and **[PRD.md](PRD.md)** (product spec) for the full rationale.

---

## Tech stack

| | |
|---|---|
| Language / UI | Swift 5 (language mode), SwiftUI |
| Min OS | iOS 18 |
| Health data | HealthKit (read-only) |
| Local storage | SwiftData |
| Notifications | UserNotifications (local only) |
| Diagnostics | MetricKit (Apple-native, no third-party SDK) |
| Design system | [IAMJARLDesignTokens](https://github.com/JarlLyng/iamjarl-design) via SPM |
| Project generation | [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`project.yml`) |

There is **no backend** — by design.

## Getting started

Prerequisites: **Xcode 26+** and **XcodeGen** (`brew install xcodegen`).

```bash
# 1. Generate the Xcode project (it is git-ignored — project.yml is the source of truth)
xcodegen generate

# 2. Open and run
open Walkful.xcodeproj
#    (select an iPhone simulator or device, then Run)

# …or build from the command line:
xcodebuild -project Walkful.xcodeproj -scheme Walkful \
  -destination 'generic/platform=iOS Simulator' build
```

> ℹ️ The `.xcodeproj` is **generated** and git-ignored. Never edit it by hand — change `project.yml` and re-run `xcodegen generate`. See [CONTRIBUTING.md](CONTRIBUTING.md).

## Project structure

```
walking-app/
├─ project.yml              # XcodeGen project definition (source of truth)
├─ Walkful/                 # App source
│  ├─ WalkfulApp.swift      # @main, SwiftData container, MetricKit
│  ├─ RootView.swift        # RootContainer (routing) + RootView (tabs)
│  ├─ Core/
│  │  ├─ Health/            # HealthKitService
│  │  ├─ Persistence/       # AppSettings (@Model)
│  │  ├─ Notifications/     # NudgeScheduler
│  │  ├─ Diagnostics/       # MetricsSubscriber (MetricKit)
│  │  ├─ Theme/             # WalkfulTheme (IAMJARL tokens) + Components
│  │  └─ Formatters.swift
│  ├─ Features/             # Onboarding / Today / Insights / Settings
│  └─ Resources/            # Assets.xcassets (layered app icon)
├─ website/                 # Marketing site (static, SEO/GEO)
├─ RESEARCH.md PRD.md TECH_PLAN.md   # Product & research docs (Danish)
└─ ARCHITECTURE.md CONTRIBUTING.md CHANGELOG.md   # Developer docs (English)
```

## Documentation

- **[ARCHITECTURE.md](ARCHITECTURE.md)** — how the code is organised and how data flows.
- **[CONTRIBUTING.md](CONTRIBUTING.md)** — setup, conventions, workflow, release.
- **[CHANGELOG.md](CHANGELOG.md)** — notable changes.
- **[PRD.md](PRD.md)** · **[RESEARCH.md](RESEARCH.md)** · **[TECH_PLAN.md](TECH_PLAN.md)** — product spec, market/science research, technical plan (Danish).
- **[website/](website/)** — marketing site + privacy policy.

## Privacy

Walkful collects nothing. Health data is read from Apple Health with explicit, granular permission, used only on-device, and never transmitted. See [website/privacy.html](website/privacy.html).

## License

Proprietary © 2026 IAMJARL. All rights reserved.
