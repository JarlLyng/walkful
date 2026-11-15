# App Store listing reference — Walkful

The living reference for Walkful's App Store presence: listing copy, privacy-label
answers, review notes, and the submit checklist. Originally the launch guide (#8);
the app has been **live since June 2026** (id [6781303837](https://apps.apple.com/app/id6781303837)).
Keep this in sync when the listing changes in App Store Connect. The Danish listing is in §2b.

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

Since the release that ships Sentry (#222), the label is **no longer "Data Not Collected"**.
Change it on release day, not before the build is live. App Store Connect → **App Privacy** →
Edit, then answer that the app collects data, and declare exactly these:

| Category | Data type | Linked to the user? | Used for tracking? | Purpose |
|---|---|---|---|---|
| Diagnostics | Crash Data | No | No | App Functionality |
| Diagnostics | Performance Data | No | No | App Functionality |
| Usage Data | Product Interaction | No | No | Analytics |

The label then reads **Data Not Linked to You: Diagnostics, Usage Data**.

- Health data is read from Apple Health **on-device only** and never transmitted. It is not
  collected and appears nowhere on the label.
- Product Interaction is the two counts: a main screen opened (from a fixed list) and move
  reminders turned on. If the counts are ever removed, drop that row.
- Nothing is linked: one shared Sentry user `anonymous`, no installation, device or vendor ID,
  no IP address stored (docs/SENTRY.md). It must stay that way for "No" to be true.
- `Walkful/PrivacyInfo.xcprivacy` declares the same three types; keep the two in step.
- The marketing website uses cookieless Umami analytics, but that is the website, not the app.

---

## 2. App information (copy-paste)

**App name** (≤30 chars) — the highest-weighted indexed field, so it carries a search
term rather than the wordmark alone. Danish already does this (`Walkful: Skridttæller`),
and `Pedometer` is the exact English parallel:
```
Walkful: Pedometer
```

**Subtitle** (≤30 chars) — unchanged, it carries the positioning:
```
Calm, private step tracker
```

**Promotional text** (≤170 chars). The only listing field that can be changed
without a submission, including while a version is in review, so it is where a
new message can go out first. Jarl pastes it on every submission, so each release
gets one. Live since 1.1.4 (read back from the store on 2026-10-13), 165 chars. **It says
"Nothing leaves your iPhone", which stops being true when the Sentry build ships**, so replace
it on that release day:
```
Every step counts. A calm, private walking tracker that turns your steps into meaning. Nothing leaves your iPhone, and Pro is one payment the whole family can share.
```
For the Sentry release and after, 164 chars:
```
Every step counts. A calm, private walking tracker that turns your steps into meaning. Your health data stays on your iPhone, and Pro is one payment for the family.
```
Used for 1.1.3, the coach line, 164 chars:
```
Every step counts. A calm, private walking tracker that turns your steps into meaning. The interval coach now guides you even with your phone locked in your pocket.
```
Older lines that said "nothing ever leaves your phone" are retired with #222; don't reuse them.
The trade is "no ads, no accounts" for the family line. Not much is lost: the
subtitle and the description both still carry the no-subscription point, and
privacy stays in the closing clause. The family line is carried nowhere else.

**Keywords** (≤100 chars, comma-separated, no spaces — this is 98):
```
walking,walk,health,fitness,activity,interval,goal,streak,counter,distance,daily,exercise,mobility
```
Nothing here repeats the name or the subtitle, because each term indexes once and a repeat
spends characters twice for nothing. `pedometer` moved up into the name; `private` and
`tracker` were already in the subtitle; `steps` is covered by `step` there. The 31 characters
that freed went to `distance`, `daily`, `exercise` and `mobility`, which nothing else covered.

**Description**:
```
Walkful turns your daily walks into something meaningful, calmly and entirely on your phone.

Apple Health gives you the numbers. Walkful gives them meaning: progress paired with what it actually does for your health, built on the science of walking rather than the 10,000-steps myth.

WHY WALKFUL
• Meaning over numbers. See what your activity means, not just a count.
• Private by design. Your health data stays on your device. No accounts, no ads, no tracking.
• Calm, never pushy. No pace-shaming, no leaderboards, no dark patterns. You compete only against your own records.
• Evidence-based. A suggested ~7,000-step goal, grounded in recent research.

FREE
• Today dashboard: progress ring, distance, active minutes, floors, this-week trend and your streak.
• Works with iPhone and Apple Watch via Apple Health.
• Gentle, optional reminders to break up long sitting.
• Home Screen and Lock Screen widgets.

WALKFUL PRO (one-time purchase, no subscription)
• Insights: week / month / year trends, a full-year consistency heatmap and a longevity-zone card.
• Mobility & fitness: walking speed, steadiness, cardio fitness (VO₂max) and resting heart rate.
• Records: best day, week and month, longest streak, most floors.
• A calm monthly recap.
• CSV export. Your data, yours to take with you.
• The interval-walking coach. Guided easy/brisk sessions to boost your fitness.

Walkful Pro supports Family Sharing, so one purchase covers everyone in your Family Sharing group.

Your health data is read from Apple Health, used only on your device, and never sent, shared or sold. To fix bugs, Walkful sends anonymous crash reports and two usage counts, with no ID and nothing from Apple Health.

Made by IAMJARL.
```

**What's New**: written per release — use the relevant [CHANGELOG](../CHANGELOG.md) section as the source, phrased for users. (The 1.0 launch notes are preserved in the git history of this file.)

> **Verifying localized metadata.** The iTunes lookup API serves metadata in the
> language you ask for, not the storefront's: use
> `curl -s "https://itunes.apple.com/lookup?id=6781303837&country=dk&lang=da_dk"`.
> Without `lang`, it returns the English metadata even for `country=dk`. Also note
> `languageCodesISO2A` describes the **app binary's** localizations (still EN only),
> never the store listing's — it is not a check for whether a localized listing is live.

> **Age ratings: the social-media questions (answered 2026-09-08, both No).** Settled, kept
> here so the reasoning is not rediscovered. They live inside the
> **Age Ratings questionnaire** (App Information → App Age Ratings → Edit), not as a field on
> the App Information page, which is why they look missing. Two questions, and for Walkful both
> answers are **No**:
>
> - *Social Media* — "redistribution, amplification, or interaction with user-generated content
>   through a social feed…". Walkful has no accounts, no servers, no feed and no UGC.
> - *Social Media Disabled for Users Under 13* — asserts the app calls the Declared Age Range
>   API and delivers only age-appropriate UGC. Walkful does neither, so Yes would be a false
>   declaration. It only carries weight when the first answer is Yes.
>
> The shareable progress card is **not** a social-media capability: it hands an image of the
> user's own data to the system share sheet. Answering Yes would force a minimum **13+** rating
> and put a Social Media descriptor on the product page, which would be wrong and would hurt in
> the audience this app is aimed at. Answer only between submissions — editing this section
> while a version is in review can require re-submitting.
>
> If Apple asks again after a future questionnaire change, the answers stay No unless the app
> actually gains a feed or user-generated content, which the roadmap does not contain.

## 2b. Danish listing (copy-paste)

The Danish localization has its own name, subtitle, keywords, promotional text and
description. They used to live in a file that left this repo, so every release they had to be
reconstructed from memory. They belong here: this is the copy itself, not the reasoning behind it.

Name, subtitle and description below are what is **live**, read back with the lookup command
in the note further down, not what an old plan proposed. The em-dashes are removed, so
submitting these updates the listing to match the house voice.

**Name** (≤30, this is 21):
```
Walkful: Skridttæller
```

**Subtitle** (≤30, this is 29):
```
Privat gå-app, ingen reklamer
```

**Promotional text** (≤170). Live since 1.1.4 (read back 2026-10-13), 154 chars. Like the
English one, it stops being true with the Sentry build, so replace it on that release day:
```
Hvert skridt tæller. En rolig, privat gå-app der gør dine skridt til mening. Intet forlader din iPhone, og Pro er én betaling, som hele familien kan dele.
```
For the Sentry release and after, 157 chars:
```
Hvert skridt tæller. En rolig, privat gå-app der gør dine skridt til mening. Dine sundhedsdata bliver på din iPhone, og Pro er én betaling for hele familien.
```
Used for 1.1.3, the coach line, 146 chars:
```
Hvert skridt tæller. En rolig, privat gå-app der gør dine skridt til mening. Intervalgang-coachen guider dig nu, også med telefonen låst i lommen.
```
Older lines with "intet forlader nogensinde din telefon" are retired with #222.

**Keywords** (≤100, this is 88). Unverified: the lookup API does not return the keyword
field, so this is the 1.0.3 plan rather than a reading of what is live. Check it against
App Store Connect before trusting it:
```
skridt,gåtur,motion,sundhed,pedometer,træning,aktivitet,mål,stime,interval,distance,7000
```

**Description**:
```
Walkful gør dine daglige gåture til noget meningsfuldt, roligt og helt privat på din telefon.

Apple Health giver dig tallene. Walkful giver dem mening: fremskridt koblet med hvad det faktisk betyder for din sundhed, bygget på videnskaben om gang frem for myten om de 10.000 skridt.

HVORFOR WALKFUL
• Mening frem for tal. Se hvad din aktivitet betyder, ikke bare en optælling.
• Privat i selve arkitekturen. Dine sundhedsdata bliver på din enhed. Ingen konti, ingen reklamer, ingen sporing.
• Rolig, aldrig anmassende. Ingen fart-skam, ingen ranglister, ingen manipulation. Du konkurrerer kun mod dine egne rekorder.
• Evidensbaseret. Et foreslået mål på ca. 7.000 skridt, baseret på nyere forskning.

GRATIS
• Today-oversigt: fremskridtsring, distance, aktive minutter, etager, ugens tendens og din stime.
• Virker med iPhone og Apple Watch via Apple Health.
• Blide, valgfrie påmindelser der bryder lange perioder med stillesiddende tid.
• Widgets til hjemmeskærmen og låseskærmen.

WALKFUL PRO (engangskøb, intet abonnement)
• Insights: tendenser for uge, måned og år samt et konsistens-heatmap for hele året.
• Mobilitet & fitness: ganghastighed, gangstabilitet, kondital (VO₂max) og hvilepuls.
• Rekorder: bedste dag, uge og måned, længste stime, flest etager.
• En rolig månedsopsamling.
• CSV-eksport. Dine data, dine at tage med.
• Interval-gang-coachen. Guidede sessioner med roligt og raskt tempo, der styrker din kondition.

Walkful Pro understøtter Family Sharing, så ét køb dækker alle i din familiedeling.

Dine sundhedsdata læses fra Apple Health, bruges kun på din enhed og bliver aldrig sendt, delt eller solgt. For at rette fejl sender Walkful anonyme crashrapporter og to optællinger af brug, uden ID og uden noget fra Apple Health.
```

The CSV-export bullet is **new**. The live Danish description omits it while the English one
lists it, so a Danish reader could not see that Pro includes it.

---

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
6. Privacy: "Your health data stays on your phone."

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

Privacy: health data is processed on-device and never transmitted. There are
no accounts. The app sends anonymous crash reports, diagnostics and two usage
counts to Sentry, with no identifier and nothing from HealthKit. App privacy
label: Diagnostics and Usage Data, not linked to the user, not used for tracking.
```

---

## 6. Submit

1. Pick the uploaded build on the version page.
2. **Select "Walkful Pro"** under In-App Purchases on the version page (first-IAP requirement).
3. Fill in everything above + screenshots + age rating (4+) + pricing (app is free; Pro is the IAP).
4. **Add for Review → Submit**.

## 7. After each approval

- Cut the CHANGELOG `[Unreleased]` section to a version heading with the date.
- Tag the release (`git tag vX.Y.Z && git push --tags`) and update the status line in README/AGENTS.md.
- Watch crash reports and hangs in Sentry (project `walkful`, environment `production`).
