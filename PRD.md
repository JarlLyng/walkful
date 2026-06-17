# PRD — Walkful

*Version 0.1 · 2026-06-17 · Bygger på [RESEARCH.md](RESEARCH.md)*

**Navn:** **Walkful** — engelsk, sammensat af "walk" + "-ful" (mindful-undertone). Internationalt publikum. Tagline-retning: *"Walkful — every step counts."*
Historik: tidligere kandidat "Afoot" blev droppet — navnet var allerede i brug i App Store (App Record Creation Error ved upload). "Walkful" er et opfundet ord → mere ejerbart og varemærke-venligt. **Endeligt bekræftet ledigt i App Store Connect; varemærke-tjek (EUIPO/DKPTO) anbefales stadig før lancering.**

---

## 1. Vision & positionering

En dansk, **100% on-device gå-app** der lægger et meningsfuldt, evidensbaseret motivationslag oven på Apple Health. Kernen er **personlig sundhed og indre motivation** — du konkurrerer kun mod dig selv. **Ingen brugerkonti, ingen servere, ingen database, ingen reklamer.** Alt bliver på telefonen.

Grundet i Bente Klarlund Pedersens "hvert skridt tæller" — ikke 10.000-myten, ikke Strava-fart-skam, ikke data-sælgende step-to-earn.

**Forretningsmodel:** Engangskøb (ingen abonnement, ingen reklamer, ingen in-app-tracking).

**Positionering i én sætning:** *"Apple Health gives you the numbers. Walkful gives them meaning — and a reason to take one more walk. All on your phone."*

### Designprincipper (afledt af evidens)
1. **Mål bevægelse, ikke skærmtid** — undgå engagement-efficacy-gabet.
2. **Få, veldesignede mekanikker** — ikke en sø af badges (afkræftet at "flere = bedre").
3. **Ingen fart-skam** — gang på gangs præmisser.
4. **Privacy er et løfte** — data minimeres, ingen salg.
5. **Ærlig sundhedskommunikation** — vis evidens, ikke vilkårlige tal.
6. **Alt på enheden** — ingen konti, ingen sky, ingen database. Privacy ved arkitektur, ikke ved politik.

---

## 2. Målgruppe

- **Primær:** Voksne danskere (30–65) der vil bevæge sig mere i hverdagen, men ikke er "trænings-typer" — afskrækkes af Strava/løbe-kultur.
- **Sekundær:** Ældre/let-syge for hvem gang er den realistiske aktivitet (Klarlunds "ikke stram lycra"-pointe).
- **Platform:** iOS først (iPhone + Apple Watch). Android senere.

---

## 3. MVP-scope

### Skal med (MVP)
| # | Feature | Begrundelse |
|---|---------|-------------|
| F1 | **Apple Health-integration** (skridt, distance, trappeture, puls, aktivitets-minutter) via HealthKit, granulært samtykke | Datagrundlag |
| F2 | **Dagligt mål, evidensbaseret & justerbart** — default ~7.000, "hvert skridt tæller"-ramme | Klarlund + Lancet 2025 |
| F3 | **Hjem-skærm: dagens fremskridt + mening** — ring/bar + kort sundhedskontekst ("du har halveret din risiko"), ikke bare et tal | Mening > vanity |
| F4 | **Historik & trends** (uge/måned), gentle streaks uden straf | Indre motivation, vanedannelse |
| F5 | **Konkurrér mod dig selv** — personlige rekorder, "slå din egen uge", egne milepæle (alt beregnet on-device) | Konkurrence virker — her vendt indad uden brugere/database |
| F6 | **Exercise-snack & anti-stillesiddende prompts** — lokale notifikationer (trapper, kort gåtur, intervalgang) | Klarlunds kerne-bidrag |
| F7 | **Privacy ved arkitektur** — alt on-device, ingen konti/sky, klar samtykke-UI | Kerne-differentiator |

### Lag ovenpå (fase 2 — stadig 100% on-device)
| # | Feature | Begrundelse |
|---|---------|-------------|
| F8 | **Intervalgang-coach** — guidet 3 min/3 min session med Watch-haptik | Klarlund: øger kondition |
| F9 | **Humør/mental check-in** koblet til gåture | Klarlunds serotonin/dopamin-pointe |

### Eksplicit IKKE
- **Sociale/hold-udfordringer mod andre** — kræver brugere, konti og en database. Fravalgt bevidst for at holde alt på telefonen. (Evidensen favoriserer det, men det er prisen for ægte on-device-privacy.)
- Penge-/krypto-belønninger (step-to-earn) — afkræftet for fastholdelse, skader privacy-brand.
- Fart-/tempo-leaderboards mod fremmede.
- Rute-/hiking-fokus (AllTrails-territorium) — evt. senere.

---

## 4. Centrale brugerflows (MVP)

1. **Onboarding:** velkomst → HealthKit-samtykke (forklaret ærligt) → vælg mål (foreslår ~7.000 med begrundelse) → notifikations-præferencer. *(Ingen konto-oprettelse — appen virker straks.)*
2. **Daglig brug:** åbn app → se dagens fremskridt + sundhedskontekst → evt. start intervalgang/exercise-snack.
3. **Passiv brug:** appen læser Watch/iPhone-data i baggrunden; sender max 1–2 venlige lokale prompts/dag.
4. **Konkurrér mod dig selv:** se personlige rekorder og "slår jeg min egen uge?" — alt beregnet lokalt på enheden.

---

## 5. Succeskriterier (måler bevægelse, ikke skærmtid)

- **Primær:** Gns. daglige skridt pr. aktiv bruger stiger over 4–8 uger (mål: +800–900/dag, jf. RCT-evidens).
- **Sekundær:** Andel der når personligt mål ≥4 dage/uge.
- **Fastholdelse:** 4-ugers retention (ikke session-længde).
- **Anti-mål:** Vi optimerer *ikke* skærmtid eller notifikations-klik for deres egen skyld.

---

## 6. Åbne spørgsmål

- **Navn** på appen.
- **Pris-punkt** for engangskøbet (fx 29–49 kr.).
- **Verificér iOS 26/HealthKit-detaljer** mod shipping-SDK før build.

*Afklaret: 100% on-device, ingen konti/database, engangskøb uden reklamer, ingen sociale udfordringer mod andre.*

---

## Design-system

Bruger **IAMJARL design-system** ([github.com/JarlLyng/iamjarl-design](https://github.com/JarlLyng/iamjarl-design)) — har allerede en Swift SPM-pakke, så det er klar til iOS.
- **Primary:** lilla `#A435D2` (light) / lime `#D0FF00` (dark)
- **Tekst/baggrund:** sort/hvid, fuld light+dark mode via tokens
- **States:** success/warning/error defineret pr. mode (WCAG AA)
- **Type:** `system-ui`, vægte 400/600/700, str. 12→36px
- **Spacing:** 4/8/12/16/20/24/32 · **Radius:** 8/12/16 · **Ikoner:** Phosphor
- **Regel:** brug kun tokens — ingen hardcodede værdier, altid light+dark.

---

## 7. Næste skridt (forslag)
1. UI-mockup af hjem-skærm + onboarding.
2. Teknisk plan: SwiftUI + HealthKit, projekt-setup (rent on-device).
3. Beslut navn + pris.
