# Contributing to Walkful

Thanks for working on Walkful! This guide covers setup, conventions, and workflow.

## Prerequisites

- **Xcode 26+**
- **XcodeGen** — `brew install xcodegen`

## Setup

```bash
xcodegen generate        # regenerate Walkful.xcodeproj from project.yml
open Walkful.xcodeproj
```

The `.xcodeproj` is **git-ignored and generated**. The source of truth is `project.yml`.
Never commit or hand-edit the project file — change `project.yml` and re-run `xcodegen generate`.

## Build & verify

```bash
# Build for simulator
xcodebuild -project Walkful.xcodeproj -scheme Walkful \
  -destination 'generic/platform=iOS Simulator' build
```

> The build resolves the `IAMJARLDesignTokens` Swift package from GitHub, so the first build needs network access.

There is no automated test target yet — verify changes by running on a simulator/device. Some paths (HealthKit authorization, real step data, notification delivery, the layered app icon) can only be verified on a **physical iPhone**.

## Code conventions

- **SwiftUI + `@Observable`** (no heavy framework). Keep state simple.
- **Design tokens only.** Use `Tokens.Palette/Spacing/Radius/FontSize` — never hardcode colors or sizes. Everything must work in light **and** dark mode.
- **UI strings in English.** Code comments may be Danish.
- **Reuse components** in `Core/Theme/Components.swift` before adding new ones.
- **Privacy is non-negotiable.** No networking, no analytics SDKs, no data leaving the device.
- Round any displayed number; respect locale via `Int.stepsFormatted`.

See [ARCHITECTURE.md](ARCHITECTURE.md) for module layout and the "add a new metric" recipe.

## Git workflow

- Branch off `main`: `feat/…`, `fix/…`, `docs/…`, `chore/…`.
- **Conventional Commits** for messages, e.g. `feat(insights): add resting heart-rate trend`.
- Open a PR; link the issue it closes (`Closes #12`). Fill in the PR template.
- Keep PRs focused.

## Issues & labels

We track all work in **GitHub Issues**.

- Types: `feature`, `bug`, `polish`, `docs`, `chore`
- Priority: `p1`, `p2`, `p3`
- Areas: `area:health`, `area:ui`, `area:notifications`, `area:storekit`, `area:watch`, `area:web`
- Milestone **v1.0 — public launch** groups everything needed to charge for the app.

Use the issue templates under `.github/ISSUE_TEMPLATE/`.

## Release / TestFlight

1. Bump `MARKETING_VERSION` / `CURRENT_PROJECT_VERSION` in `project.yml`, then `xcodegen generate`.
2. Xcode → Product → **Archive** (Any iOS Device, Release). Signing uses the IAMJARL team (`DEVELOPMENT_TEAM` in `project.yml`).
3. **Distribute → TestFlight & App Store** → upload.
4. The App Store Connect app record must exist first (bundle id `com.iamjarl.walkful`).

Known upload gotchas (already handled in `project.yml`): both HealthKit usage strings are required even though we only read; `ITSAppUsesNonExemptEncryption=NO` answers the export-compliance prompt.
