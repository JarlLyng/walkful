# App Store listing reference — Walkful

The living reference for Walkful's App Store presence: listing copy, privacy-label
answers, review notes, and the submit checklist. Originally the launch guide (#8);
the app has been **live since June 2026** (id [6781303837](https://apps.apple.com/app/id6781303837)).
Keep this in sync when the listing changes in App Store Connect.
(The **Danish** localized listing lives in the private strategy hub — `iamjarl-strategy/Walkful/aso.md`.)

App: **Walkful** · Bundle ID `com.iamjarl.walkful` · Team: IAMJARL (`KDWZ3WNLDK`)
Category: **Health & Fitness** · Age rating: **4+** · Sign-in required: **No**

---

## 0. Prerequisites (done at launch — kept for reference)

- [x] Paid Applications Agreement active (App Store Connect → Business).
- [x] IAP `com.iamjarl.walkful.pro` created (Non-Consumable) — approved with 1.0.
- [x] App record exists. Builds now arrive via **Xcode Cloud** from the `release` branch (Xcode Cloud owns the build number — see CONTRIBUTING.md).

> ⚠️ **First IAP ships with the app version.** On the version page, under *In-App Purchases*, **select "Walkful Pro"** so it's reviewed together with the build. Otherwise the IAP stays unreviewed.

---

## 1. App Privacy ("nutrition label")

App Store Connect → **App Privacy** → answer **"Data Not Collected"**.

- Walkful reads Apple Health data **on-device only**; it is never transmitted, so it is *not collected*.
- No analytics/advertising SDKs in the app. (Crash/perf via Apple MetricKit is handled by Apple under the user's existing system consent — not data you collect.)
- The marketing website uses cookieless Umami analytics, but that is the website, not the app.

Result: the label reads **Data Not Collected** — a genuine differentiator.

---

## 2. App information (copy-paste)

**Subtitle** (≤30 chars):
```
Calm, private step tracker
```

**Promotional text** (≤170 chars, editable anytime without review):
```
Every step counts. A calm, private walking tracker that turns your steps into meaning — no ads, no accounts, and nothing ever leaves your phone.
```

**Keywords** (≤100 chars, comma-separated, no spaces — this is 97):
```
steps,walking,pedometer,walk,health,fitness,activity,private,interval,goal,streak,counter,tracker
```

**Description**:
```
Walkful turns your daily walks into something meaningful — calmly, and entirely on your phone.

Apple Health gives you the numbers. Walkful gives them meaning: progress paired with what it actually does for your health, built on the science of walking rather than the 10,000-steps myth.

WHY WALKFUL
• Meaning over numbers — see what your activity means, not just a count.
• Private by design — everything stays on your device. No accounts, no servers, no ads, no data collection.
• Calm, never pushy — no pace-shaming, no leaderboards, no dark patterns. You compete only against your own records.
• Evidence-based — a suggested ~7,000-step goal, grounded in recent research.

FREE
• Today dashboard: progress ring, distance, active minutes, floors, this-week trend and your streak.
• Works with iPhone and Apple Watch via Apple Health.
• Gentle, optional reminders to break up long sitting.
• Home Screen and Lock Screen widgets.

WALKFUL PRO (one-time purchase — no subscription)
• Insights: week / month / year trends, a full-year consistency heatmap and a longevity-zone card.
• Mobility & fitness: walking speed, steadiness, cardio fitness (VO₂max) and resting heart rate.
• Records: best day, week and month, longest streak, most floors.
• A calm monthly recap.
• CSV export — your data, yours to take with you.
• The interval-walking coach — guided easy/brisk sessions to boost your fitness.

Walkful collects nothing. Your health data is read from Apple Health, used only on your device, and never shared or sold.

Made by IAMJARL.
```

**What's New**: written per release — use the relevant [CHANGELOG](../CHANGELOG.md) section as the source, phrased for users. (The 1.0 launch notes are preserved in the git history of this file.)

**Other fields:**
- **Copyright:** `© 2026 IAMJARL`
- **Primary category:** Health & Fitness
- **Secondary category** (optional): Lifestyle

---

## 3. URLs

- **Support URL:** https://walkful.iamjarl.com
- **Marketing URL:** https://walkful.iamjarl.com
- **Privacy Policy URL:** https://walkful.iamjarl.com/privacy.html

---

## 4. Screenshots

Required: **6.9" iPhone** (e.g. 16 Pro Max) and **6.5"/6.7"**. Capture from a device/simulator with Pro unlocked and some step history.

Suggested set (5–6), each with a short caption:
1. Today dashboard (light) — "Every step counts."
2. Today meaning line + nudge — "Numbers with meaning. Calm, never pushy."
3. Insights trends + year heatmap (dark) — "See your year at a glance."
4. Mobility & fitness — "Health that matters: speed, steadiness, cardio fitness."
5. Records + monthly recap — "Beat your own best."
6. Privacy — "Everything stays on your phone. Data Not Collected."

Tip: use the framed brand colours (purple light / lime dark). Keep captions short.

---

## 5. Review information

**Sign-in required:** No (no demo account needed).

**Review Notes** (paste):
```
No account or sign-in is required to use Walkful.

Health data: Walkful reads steps, distance, stairs and active minutes from
Apple Health (read-only — it never writes data). On first launch the Today
tab shows a "Connect Apple Health" card; tap Connect and allow access. If the
test device has no activity data, step counts may show 0 — you can add sample
data in the Health app (Browse → Activity → Steps → Add Data) to see the
dashboard populate.

In-App Purchase — "Walkful Pro" (com.iamjarl.walkful.pro): a one-time,
non-consumable unlock. It unlocks the Insights tab and the interval-walking
coach (reached from the Today tab). Both are otherwise locked behind a paywall.
Please test the purchase via Sandbox.

Privacy: all data is processed on-device. There are no servers, no accounts and
no analytics. App privacy label: Data Not Collected.
```

---

## 6. Submit

1. Pick the uploaded build on the version page.
2. **Select "Walkful Pro"** under In-App Purchases on the version page (first-IAP requirement).
3. Fill in everything above + screenshots + age rating (4+) + pricing (app is free; Pro is the IAP).
4. **Add for Review → Submit**.

## 7. After each approval

- Cut the CHANGELOG `[Unreleased]` section to a version heading with the date.
- Tag the release (`git tag vX.Y.Z && git push --tags`) and update the status line in README/CLAUDE.md.
- Watch MetricKit crash reports in Xcode Organizer.
