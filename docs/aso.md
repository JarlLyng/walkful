# Walkful — App Store Optimization (ASO)

Concrete metadata to enter in App Store Connect, plus what to measure. Strategy
(see [TARGETAUDIENCE.md](../TARGETAUDIENCE.md)): **English listing is the growth
lever** (US/UK/CA/AU + privacy-conscious EU); **Danish is the beachhead** (home
traction, matches the `/da/` site). Lead with *private · no ads · no
subscription · 7,000-step science*.

> **The golden rule:** Apple indexes **title + subtitle + keywords together**.
> Never repeat a word across them — every duplicate wastes a slot. Singular ≈
> plural (Apple stems), so "step" covers "steps". No spaces in the keywords
> field. Don't put "app", "free", or your category name in keywords (wasted).

---

## 1. English (primary / default locale)

**App name / title** (≤30 chars) — carries the most weight; lead with the
highest-volume search term:
```
Walkful: Step Counter
```
*(21 chars. A/B alternative to test: `Walkful – Pedometer & Steps` (27).)*

**Subtitle** (≤30) — add new keywords + the differentiator, no repeats:
```
Private walking app, no ads
```
*(27 chars — adds "private", "walking", "ads".)*

**Keywords** (≤100, comma-separated, no spaces, no words already in title/subtitle):
```
pedometer,steps,health,fitness,activity,tracker,goal,streak,interval,distance,offline,move,7000
```
*(95 chars.)*

Promotional text, description, and "What's New" stay as in
[app-store-release.md](app-store-release.md) — those are conversion copy, not
indexed for search, and already on-message.

---

## 2. Danish (add as a localized listing — matches the /da/ site)

**Title** (≤30):
```
Walkful: Skridttæller
```
*(21 chars — "skridttæller" is the dominant DK search term.)*

**Subtitle** (≤30):
```
Privat gå-app, ingen reklamer
```
*(29 chars.)*

**Keywords** (≤100, no repeats of title/subtitle):
```
skridt,gåtur,motion,sundhed,pedometer,træning,aktivitet,mål,stime,interval,distance,7000
```
*(88 chars.)*

**Promotional text** (≤170):
```
Hvert skridt tæller. En rolig, privat gå-app der gør dine skridt til mening — ingen reklamer, ingen konti, og intet forlader nogensinde din telefon.
```

**Description** (Danish):
```
Walkful gør dine daglige gåture til noget meningsfuldt — roligt, og helt på din telefon.

Apple Health giver dig tallene. Walkful giver dem mening: fremskridt koblet til hvad det faktisk gør for dit helbred, bygget på videnskaben om gang frem for myten om de 10.000 skridt.

DERFOR WALKFUL
• Mening frem for tal — se hvad din aktivitet betyder, ikke bare et tal.
• Privat af design — alt bliver på din enhed. Ingen konti, ingen servere, ingen reklamer, ingen dataindsamling.
• Roligt, aldrig pågående — ingen tempo-skam, ingen ranglister. Du konkurrerer kun mod dine egne rekorder.
• Evidensbaseret — et anbefalet mål på ~7.000 skridt, forankret i ny forskning.

GRATIS
• Dagens dashboard: fremskridtsring, distance, aktive minutter, etager, ugens trend og din stime.
• Virker med iPhone og Apple Watch via Apple Health.
• Blide, valgfrie påmindelser om at bryde langvarig stillesidden.
• Widgets til Hjemmeskærm og Låseskærm.

WALKFUL PRO (engangskøb — intet abonnement)
• Indsigter: uge/måned/år-trends og et helårs konsistens-varmekort.
• Mobilitet & form: ganghastighed, stabilitet, kondital (VO₂max) og hvilepuls.
• Rekorder: bedste dag, uge og måned, længste stime, flest etager.
• Et roligt månedligt tilbageblik.
• Intervalgang-coachen — guidede rolige/raske intervaller der booster din form.

Walkful indsamler intet. Dine sundhedsdata læses fra Apple Health, bruges kun på din enhed, og deles eller sælges aldrig.

Lavet af IAMJARL.
```

**What's New** (Danish):
```
Den første offentlige udgave af Walkful — en rolig, privat, evidensbaseret gå-app.
• Dagens dashboard med fremskridt, trends og stimer
• Widgets til Hjemmeskærm og Låseskærm
• Blide, stillesidden-bevidste påmindelser
• Walkful Pro: dybe indsigter, mobilitet & form, rekorder og en intervalgang-coach
```

---

## 3. Screenshot captions (benefit-led, persona-aligned)

We have angled frames in `app store screens/Preview 01–04.png`. Recommended
order and captions (the first 2–3 are what most people see in search results,
so front-load the hooks):

1. **Walking, made meaningful.** — the emotional hook.
2. **Private. No ads. No subscription.** — the #1 differentiator (privacy persona).
3. **7,000 steps, not 10,000.** — the science (longevity persona).
4. **Go deep on your data.** — Pro insights/heatmap.
5. **A calm interval coach.** — Pro coach (use the real `coach-dark` screen).

Keep captions short, sentence-case, one idea each. Localise to Danish for the DK listing.

---

## 4. What to measure & iteration cadence

In **App Store Connect → App Analytics**:

- **Impressions** → **Product Page Views** → **Installs**, and the two conversion
  rates between them. This tells you whether to fix *discovery* (keywords/title)
  or *conversion* (screenshots/subtitle/icon).
- **Conversion rate (CR)** by source (Search vs Browse vs Referral) and by territory.
- Search **keyword performance** (which terms drive impressions/installs).

**Cadence:**
- Review every **2–4 weeks**; change **one thing at a time** so you can attribute the effect.
- Iterate **subtitle + keywords** freely (low risk). Change the **title sparingly** — it carries ranking momentum and resets discovery.
- Use **Product Page Optimization (A/B test)** for screenshots/icon when you have enough traffic.
- Refresh **promotional text** for seasonal hooks (New Year "move more", etc.) — it's editable without review.

## 5. Quick wins checklist

- [ ] Set the English title/subtitle/keywords above in App Store Connect.
- [ ] Add the **Danish localization** (title/subtitle/keywords/description/promo).
- [ ] Re-caption screenshots benefit-first; swap in the real coach screen.
- [ ] Turn on **App Analytics** and note a baseline (impressions, CR) this week.
- [ ] Ask early users for reviews — ratings volume lifts ranking (app also prompts in-app).
