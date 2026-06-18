# Roadmap & handoff

Orientation for anyone picking up Walkful. Pair this with [README](../README.md),
[ARCHITECTURE](../ARCHITECTURE.md) and [CONTRIBUTING](../CONTRIBUTING.md).

## Where the project stands (June 2026)

- **App:** v0.2 (build 6) **submitted to App Store review.** Free app + one-time **Walkful Pro** IAP.
- **Shipped:** HealthKit dashboard, Today/Insights/Settings, interval-walking coach, sedentary-aware nudges, Home/Lock Screen widgets, Pro insights (trends, year heatmap, mobility & fitness, records, recap), the **Aurora** visual design, full **accessibility** (Dynamic Type, VoiceOver, Reduced Motion).
- **Marketing site:** live at **walkful.iamjarl.com** (+ Danish `/da/`), auto-deployed from `website/` via GitHub Pages.
- **Privacy:** 100% on-device. App Store label **Data Not Collected**.

## How work is tracked

- **GitHub Issues** are the backlog. Every change goes through a branch + PR that closes an issue.
- **Milestones:** `v1.0 — public launch` (what shipped) · `Post-launch / v1.x` (everything next).
- **Labels:** type (`feature`/`bug`/`polish`/`chore`/`docs`), priority (`p1`–`p3`), area (`area:health/ui/notifications/storekit/watch/web`), plus `marketing` and `infra`.

## Suggested order for a new developer

1. **Get oriented & safe to change things** — `infra` issues first:
   - Add a unit-test target ([#45]) and CI on PRs ([#46]).
   - Run the on-device verification checklist ([#47]) — confirms the things the simulator can't.
2. **Product depth** (the paid value): in-app Danish localization ([#40]), data export ([#41]), mortality-risk context ([#42]), more widgets ([#44]), units/adaptive goal ([#43]).
3. **Experience polish:** onboarding polish ([#7]), insight→action ([#6]), delight/animations ([#10]).
4. **Platform:** Apple Watch app + complication ([#4]).
5. **Growth:** App Store badge URL post-approval ([#36]), ASO + Danish listing ([#37]), launch/press ([#38]), site content ([#39]).
6. **Phase 2:** mood/mental check-in ([#13]); trademark check ([#11]).

(Issue numbers are a snapshot — see the live [issues list](../../issues) and milestones.)

## Guardrails (please keep)

- **Privacy by architecture** — no networking, no analytics SDKs, nothing leaves the device.
- **Meaning over vanity metrics** — features should help people move more, not maximize screen time.
- **Tokens + Aurora only** — no hardcoded colors/sizes; use `Tokens.*` and `Tokens.TextStyle.*` (Dynamic Type).
- **Honest health claims** — keep "associated with" phrasing; the app is *not* a medical device.

## Release notes / process

See [app-store-release.md](app-store-release.md) for the listing copy, privacy-label answers, review notes, and the submit checklist (incl. the first-IAP-with-version requirement and the `xcodegen generate` step).
