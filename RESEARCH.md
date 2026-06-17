# Gå-app — Research & Koncept

*Udarbejdet 2026-06-17. Bygger på deep-research (27 kilder, 110 påstande, 21 verificeret adversarielt) + uddybende kildelæsning.*

---

## 1. Konkurrentanalyse — hvad gør de godt og skidt

| App | Stærkt | Svagt | Læring for os |
|-----|--------|-------|---------------|
| **Apple Health / Fitness** | Gratis, forinstalleret, sømløs data fra iPhone + Watch | "No motivation layer — just numbers". Ingen historie eller tilskyndelse | Vi skal levere motivationslaget *oven på* Apples rådata |
| **Google Fit** | Gratis, rent pedometer, deler på tværs | Begrænset socialt/gamification | — (Android, ikke vores primære platform) |
| **Strava** | Stærk GPS, analytik, stort community | Tempo-sammenligninger virker *demotiverende* for gående; aggressiv paywall; få gå-udfordringer | Undgå at sammenligne folk på fart — gående straffes |
| **Pacer / StepsApp / Pedometer++** | Simple, fokuserede skridttællere | Lavt engagement over tid; "tal uden mening" | Tal alene fastholder ikke |
| **WeWard / Sweatcoin / StepBet** ("get paid to walk") | Ekstrinsisk belønning, treasure-hunts, satsnings-udfordringer | Indtjening latterligt lav ($1–5/md for normale brugere), batteridræn, udbetalingsproblemer, **privacy-bekymringer** (sælger data) | Ekstrinsiske penge-belønninger er en blindgyde for fastholdelse — se §3 |
| **AllTrails / Footpath** | Rutekort, opdagelse af gåture | Mere til vandring/hiking end hverdagsgang | Rute-opdagelse er en mulig niche-feature |

**Markedshuller vi kan ramme:**
- **Meningsfuldt motivationslag oven på Apple Health** — Apple har dataene, ikke historien.
- **Gang behandlet på gangs præmisser** (ikke som langsomt løb à la Strava).
- **Privacy som differentiator** — modsætning til data-sælgende step-to-earn apps. (Bemærk: "80% af fitness-apps sælger data" og en konkurrent ("Cloudless Steps") markedsfører sig allerede på privacy — verificeret som reelt positioneringsfelt, men hviler på én ikke-auditeret App Store-label, så *medium* sikkerhed.)
- **Dansk-venligt, evidensbaseret indhold** koblet til Bente Klarlund-tilgangen.

---

## 2. Bente Klarlund Pedersen — evidens oversat til features

**Skridt:**
- 10.000-skridt er en **myte** — stammer fra et japansk skridttæller-brand fra 1965 ("manpo-kei" = markedsføring, ikke videnskab).
- "Går du 2.000–4.000 skridt, halverer du dødeligheden; ved 4.000–8.000 halverer du igen." Kurven **flader ud omkring 7.000 skridt**.
- Budskab: **"Hvert skridt tæller."**
- *(Bekræftet af 2025 Lancet-metaanalyse: 7.000 vs 2.000 skridt = 47% lavere dødelighed; gevinst-knæk ved 5.000–7.000. Skridt knyttet til lavere risiko på tværs af hjerte-kar, kræft-dødelighed, type 2-diabetes, demens, depression og fald.)*

**Intensitet:**
- **Intervalgang**: skiftevis 3 min langsomt / 3 min så hurtigt du kan — "kan øge konditionen betragteligt."
- Moderat intensitet > lav, men *daglig bevægelse* er det vigtigste.

**Mikro-pauser / "exercise snacks":**
- Stillesiddende arbejde er skadeligt; korte, lidt hårde aktiviteter (under 1 min) hæver pulsen og virker.
- Eksempler: squats i kaffepausen, 5 push-ups, trapper.
- Forskning: **3 trappeture × 3 dagligt styrkede ben/kondition på 6 uger.**
- Nøgle: indlejr som **små faste elementer i hverdagen** → vane.

**Mental sundhed:** Gang fremmer serotonin/dopamin/noradrenalin → glædes- og belønningsfølelse. Sænker blodtryk og kolesterol.

**Gang vs. løb:** Gang er mere tilgængeligt, særligt for syge/ældre — "behøver ikke skrue sig ned i stram lycra."

→ **Feature-oversættelse:** evidensbaseret mål (~7.000, justerbart, "hvert skridt tæller"-ramme) · intervalgang-coach · "exercise snack"/trappe-prompts mod stillesiddende tid · humør/mental vinkel · ingen fart-skam.

---

## 3. Adfærdsændring — hvad virker (verificeret)

**Virker:**
- **Konkurrence er den mest effektive og holdbare gamification** (STEP UP RCT: +920 skridt/dag, vedligeholdt). Vores research *afkræftede* påstanden om at konkurrence-effekten falder hurtigt over tid → effekten holder.
- **Intrinsisk motivation slår ekstrinsisk for fastholdelse** (Frontiers 2024, β=0,501). Penge/badges fastholder ikke.
- Behaviorelt designet gamification giver reelle (om end moderate) gevinster.

**Pas på / afkræftet:**
- "Flere spil-elementer er altid bedre" → **afkræftet** (0-3). Ikke fyld appen med mekanikker.
- "Teori-styret gamification slår altid atheoretisk" → afkræftet.
- "Ekstrinsiske belønninger forstærker intrinsisk motivation" → afkræftet (1-2).
- **Engagement-Efficacy Gap**: at maksimere *engagement* (skærmtid, streaks for streaks' skyld) kan underminere det egentlige mål (mere bevægelse). Undgå vanity-engagement.

→ **Design-princip:** Få, veldesignede mekanikker · social/holdkonkurrence frem for penge · understøt indre motivation (mening, mestring, autonomi) · mål succes i *bevægelse*, ikke skærmtid.

---

## 4. Teknik — Apple Health & Watch (verificeret)

- **HealthKit** er central repository for sundhedsdata; læser både iPhone- og Watch-data.
- **Granulære tilladelser**: brugeren giver adgang per datatype (skridt, distance, puls, trappeture…). Eksplicit samtykke kræves.
- **iOS 26 / WWDC25**: iPhone kan nu køre native workout-sessions (ikke kun via Watch).
- *(Platform-detaljer er WWDC25/iOS 26 — bør verificeres mod shipping-SDK før build.)*

---

## 5. Foreslået koncept (udkast)

**Arbejdstitel:** *(åben)*
**Pitch:** En dansk, privacy-først gå-app der lægger et **meningsfuldt, evidensbaseret motivationslag** oven på Apple Health — bygget på Bente Klarlund-tilgangen "hvert skridt tæller", ikke 10.000-myten eller fart-skam.

**Bærende søjler:**
1. **Evidensbaseret mål, ikke vilkårligt** — start ~7.000, personligt justerbart, ærlig "hvert skridt tæller"-ramme.
2. **Intensitet & exercise snacks** — intervalgang-coach + venlige prompts om at bryde stillesiddende tid (trapper, mikro-bevægelse).
3. **Social konkurrence, ikke penge** — holdudfordringer mod venner/kolleger (den mest holdbare mekanik), uden fart-skam.
4. **Privacy som løfte** — data bliver på enheden/sundt minimum, ingen datasalg. Klar modpol til step-to-earn.
5. **Mening frem for vanity-metrics** — vis sundhedsgevinst/humør, ikke bare tal og streaks.

---

## Kilder (udvalg)
- Lancet Public Health 2025 — skridt & dødelighed (primær)
- STEP UP RCT, PubMed 31498375 — gamification/konkurrence (primær)
- Frontiers 2024, PMC10807424 — intrinsisk vs ekstrinsisk motivation (primær)
- Apple HealthKit developer docs + WWDC25 #322 (primær)
- Hjerteforeningen, videnskab.dk, DR, fagligsenior.dk — Bente Klarlund (sekundær)
- motion-app.com, earnlab.com — konkurrent-teardown (blog)
