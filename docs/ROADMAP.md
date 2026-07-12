# Roadmap & handoff

Orientation for anyone picking up Walkful. Pair this with [README](../README.md),
[ARCHITECTURE](../ARCHITECTURE.md) and [CONTRIBUTING](../CONTRIBUTING.md).

## Where the project stands (July 2026)

- **App:** **Live on the App Store** (id [6781303837](https://apps.apple.com/app/id6781303837)) — currently v1.0.2, with 1.0.3 in review. Free app + one-time **Walkful Pro** IAP. Open source under AGPL-3.0.
- **Shipped:** HealthKit dashboard (Today/Insights/Settings), interval-walking coach, sedentary-aware nudges, Home/Lock Screen widgets (incl. the systemMedium "This week"), Pro insights (trends, year heatmap, mobility & fitness, longevity-zone card, records, recap), CSV export, km/mi units, adaptive goal, App Store review prompt + Rate/Share, the **Aurora** visual design, full **accessibility** (Dynamic Type, VoiceOver, Reduced Motion).
- **Infra:** unit tests (`Tests/`, 30+ cases) run by **GitHub Actions CI on every PR**; releases build via **Xcode Cloud** from the `release` branch; `main` is branch-protected.
- **Marketing site:** live at **walkful.iamjarl.com** (+ Danish `/da/`, `/learn/` content hub, `/support.html`), auto-deployed from `website/` via GitHub Pages.
- **Privacy:** 100% on-device. App Store label **Data Not Collected**.

## How work is tracked

- **GitHub Issues** are the backlog. Every change goes through a branch + PR that closes an issue; CI must pass before merge.
- **Milestones:** `v1.0 — public launch` (what shipped) · `Post-launch / v1.x` (everything next).
- **Labels:** type (`feature`/`bug`/`polish`/`chore`/`docs`), priority (`p1`–`p3`), area (`area:health/ui/notifications/storekit/watch/web`), plus `marketing` and `infra`.

## What's next

The remaining meaningful work, roughly in order of impact:

1. **Apple Watch app + complication** ([#4]) — the largest missing platform piece; Watch data already flows in via Health, but there is no Watch target.
2. **In-app Danish localization + i18n infrastructure** ([#40]) — the App Store listing is already localized to Danish; the app UI is English-only.
3. **Step de-dup investigation** ([#53]) — totals can run high vs Health/Fitness with iPhone+Watch; needs a device pair to reproduce.
4. **Mood / mental check-in** ([#13]) — phase-2 concept.
5. Smaller cleanups: [#89] (minor correctness), [#90] (contributor build experience), [#93] (code of conduct).

(Issue numbers are a snapshot — see the live [issues list](../../issues) and milestones.)

## Guardrails (please keep)

- **Privacy by architecture** — no networking, no analytics SDKs, nothing leaves the device.
- **Meaning over vanity metrics** — features should help people move more, not maximize screen time.
- **Tokens + Aurora only** — no hardcoded colors/sizes; use `Tokens.*` and `Tokens.TextStyle.*` (Dynamic Type).
- **Honest health claims** — keep "associated with" phrasing; the app is *not* a medical device.

## Release notes / process

See [app-store-release.md](app-store-release.md) for the listing reference (copy, privacy label, review notes) and [CONTRIBUTING.md](../CONTRIBUTING.md) for the release flow (bump `MARKETING_VERSION` → merge to `main` → fast-forward `release` → Xcode Cloud builds and uploads).
