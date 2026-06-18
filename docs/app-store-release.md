# App Store release guide — Walkful

Everything needed to take Walkful from TestFlight to a public App Store release.
Copy-paste blocks are ready to use; adjust wording to taste. (#8)

App: **Walkful** · Bundle ID `com.iamjarl.walkful` · Team: IAMJARL (`KDWZ3WNLDK`)
Category: **Health & Fitness** · Age rating: **4+** · Sign-in required: **No**

---

## 0. Prerequisites

- [x] Paid Applications Agreement active (App Store Connect → Business).
- [x] IAP `com.iamjarl.walkful.pro` created, **Ready to Submit** (Non-Consumable).
- [ ] Latest build uploaded (currently 0.2, build 4 — Pro v2). Bump build for each upload.
- [ ] App record exists (it does — created with the IAP).

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

**Keywords** (≤100 chars, comma-separated, no spaces):
```
steps,walking,pedometer,step counter,walk,health,fitness,activity,private,interval,goal,streak,daily
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
• Insights: week / month / year trends and a full-year consistency heatmap.
• Mobility & fitness: walking speed, steadiness, cardio fitness (VO₂max) and resting heart rate.
• Records: best day, week and month, longest streak, most floors.
• A calm monthly recap.
• The interval-walking coach — guided easy/brisk sessions to boost your fitness.

Walkful collects nothing. Your health data is read from Apple Health, used only on your device, and never shared or sold.

Made by IAMJARL.
```

**What's New** (release notes for the first public version):
```
The first public release of Walkful — a calm, private, evidence-based walking tracker.
• Today dashboard with progress, trends and streaks
• Home Screen & Lock Screen widgets
• Gentle, sedentary-aware reminders
• Walkful Pro: deep insights, mobility & fitness metrics, records, and an interval-walking coach
```

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

## 7. After approval

- Tag the release: `git tag v1.0.0 && git push --tags` (and add release notes).
- Announce the site (already live at walkful.iamjarl.com).
- Watch MetricKit crash reports in Xcode Organizer.
