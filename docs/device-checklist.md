# On-device verification checklist

Some things can't be verified in the iOS Simulator — HealthKit has no real
activity data, notifications/background tasks don't fire realistically, widgets
and the layered app icon need a real Home/Lock Screen, and StoreKit purchases
need a Sandbox account. Run this checklist on a **physical iPhone** (and Apple
Watch where noted) before each App Store submission.

> Tip: install via TestFlight (release build) for the most representative run.
> For a quick dev pass, run the Debug build from Xcode on a connected device.

## Setup
- [ ] Signed into iCloud/Apple ID on the device; Health app has some step data
      (walk around, or add steps in **Health → Browse → Activity → Steps → Add Data**).
- [ ] For IAP: a **Sandbox tester** account configured
      (**Settings → Developer → Sandbox Apple Account** on iOS 16+).

## HealthKit (authorized data path)
- [ ] First launch → onboarding → **Connect Apple Health** → allow read access.
- [ ] Today shows real steps, distance, active minutes, floors (not zeros).
- [ ] Progress ring fills to today's value and the "meaning" line matches.
- [ ] **Relaunch the app (cold)** → it goes **straight to the dashboard**, does
      **not** re-show the "Connect Apple Health" card (regression guard for #54).
- [ ] Insights (Pro) populates: trends, year heatmap, longevity-zone card,
      best time of day, records, recap, lifetime distance.
- [ ] Insights shows the **loading skeleton** only briefly — the screen appears
      as soon as history is ready; heavier metrics (mobility, lifetime distance)
      fill in after without blocking (two-phase load).
- [ ] Apple Watch-derived metrics (walking speed/steadiness, VO₂max, resting HR)
      appear if you wear a Watch; hide gracefully if not.

## Units & adaptive goal (#43)
- [ ] Settings → **Units** → Miles → distance switches to `mi` on Today + Insights.
- [ ] Settings → **Adaptive goal** on → after a few high-average days the daily
      goal nudges up (never down).
- [ ] With adaptive goal ON, **manually set a goal** (e.g. 7,500), leave Settings
      and return to Today → the goal **stays** at your value that day; it adjusts
      at most once per day (regression guard for #81).

## Delight (#10)
- [ ] Crossing the daily goal fires a **success haptic** (once per day) and shows
      the "Goal reached today" pill.
- [ ] With **Reduce Motion** on, ring/pill don't animate (haptic still fires).

## Review prompt & Rate/Share
- [ ] Settings → **Rate Walkful** opens the App Store review sheet; **Share
      Walkful** opens the share sheet with the App Store link.
- [ ] The automatic review prompt appears at most **once ever**, and only at a
      high point (goal reached + 3-day streak). No nagging on later launches.

## Notifications & background nudges
- [ ] Onboarding requests notification permission; granting enables nudges.
- [ ] Settings → Nudges: toggle + active-hours pickers persist.
- [ ] A move nudge is delivered only after genuine sedentary time within the
      active-hours window (background; opportunistic — may take a while).

## Widgets
- [ ] Add the **Steps** widget (systemSmall) to the Home Screen — shows ring + steps.
- [ ] Add the **This week** widget (systemMedium) — 7-day bars, total, avg/day;
      bars meeting the goal are full colour (#44).
- [ ] Lock Screen accessory widgets: Steps (circular/inline/rectangular) and
      This week (rectangular) render and update.
- [ ] Widgets refresh after opening the app (snapshot via App Group).
- [ ] After midnight **without opening the app**, widgets show 0 — not
      yesterday's count (regression guard for #85).

## In-App Purchase (Sandbox)
- [ ] Insights/coach show the paywall when **not** Pro.
- [ ] Purchase **Walkful Pro** in Sandbox → Insights + interval coach unlock.
- [ ] **Restore purchase** works on a fresh install (same Sandbox account).
- [ ] Settings → Your data → **Export steps (CSV)** is Pro-gated; for Pro it
      opens the share sheet with a valid CSV (#41).

## App icon & appearance
- [ ] Layered app icon renders correctly in **light**, **dark**, and **tinted**
      Home Screen modes.
- [ ] App looks correct in light and dark; contrast is comfortable.

## Accessibility
- [ ] **Dynamic Type** at a large accessibility size: text scales, layouts hold.
- [ ] **VoiceOver**: the ring and stat chips read meaningful labels; decorative
      charts are skipped.
- [ ] **Reduce Motion**: animations are suppressed (see Delight above).

## Crash/metrics
- [ ] MetricKit subscriber is active (no third-party SDK) — nothing leaves the
      device; "Data Not Collected" stays honest.
