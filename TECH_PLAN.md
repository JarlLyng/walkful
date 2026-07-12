# Teknisk plan — Walkful

*Version 0.1 · 2026-06-17 · Bygger på [PRD.md](PRD.md)*

> **Historisk spec (juni 2026).** Bevaret for kontekst — dele af planen (fx datamodellerne) blev aldrig implementeret som beskrevet. Se [ARCHITECTURE.md](ARCHITECTURE.md) for hvordan appen faktisk er bygget.

Princip: **100% on-device, ingen backend.** Alt der ikke skal forlade telefonen, gør det ikke. Privacy er en arkitektonisk egenskab, ikke en indstilling.

---

## 1. Stack & rammer

| Område | Valg | Begrundelse |
|--------|------|-------------|
| Sprog/UI | **Swift + SwiftUI** | Native, moderne, bedst til HealthKit/Watch |
| Min. iOS | **iOS 18** | Dækker langt størstedelen af aktive enheder i 2026; giver `@Observable`, moderne SwiftData, widgets |
| Arkitektur | **MVVM-light** med `@Observable` view-models | Enkelt, testbart, ingen tung framework |
| Sundhedsdata | **HealthKit** (`HKHealthStore`) | Eneste kilde til skridt/distance/trapper/puls |
| Lokal lagring | **SwiftData** (mål, rekorder-cache, prefs, senere humør-log) | On-device, ingen sky |
| Notifikationer | **UserNotifications** (kun lokale) | Exercise-snack/anti-stillesiddende prompts uden server |
| Design | **IAMJARL** via Swift Package Manager | Allerede en SPM-pakke; tokens for farver/spacing/radius |
| Ikoner | **Phosphor** (SwiftUI-pakke) | Jf. IAMJARL |
| Analytics/SDK | **Ingen** | Privacy-løfte; intet tredjeparts-tracking |

### Apple Watch — vigtig afklaring
Vi behøver **ikke** en separat watchOS-app i MVP for at "connecte til uret". Hvis brugeren har et Apple Watch, **flyder dets skridt/puls automatisk ind i HealthKit**, og vi læser den samlede, afduplikerede værdi. En dedikeret watchOS-app + komplikation + live intervalgang-haptik er **fase 2**.

---

## 2. Projektstruktur

```
Walkful/
├─ WalkfulApp.swift              // @main, app-entry, theme-injection
├─ Core/
│  ├─ Health/
│  │  ├─ HealthKitService.swift     // auth, queries, observers
│  │  └─ HealthModels.swift          // DaySteps, WeekSummary, Metric
│  ├─ Persistence/
│  │  ├─ Goal.swift                  // @Model: dagligt mål
│  │  ├─ PersonalRecord.swift        // @Model: bedste dag/uge
│  │  └─ AppSettings.swift           // @Model: notif-prefs, units
│  ├─ Notifications/
│  │  └─ NudgeScheduler.swift        // lokale prompts
│  └─ Theme/
│     └─ WalkfulTheme.swift            // bro fra IAMJARL-tokens → SwiftUI
├─ Features/
│  ├─ Onboarding/                    // velkomst → HealthKit → mål → notif
│  ├─ Today/                         // hjem: ring, mening, snack-prompt
│  ├─ Week/                          // dig-vs-din-bedste + rekorder
│  └─ Settings/                      // mål, prefs, privacy-info
└─ Resources/                        // assets, lokalisering (en)
```

---

## 3. HealthKit-integration

**Datatyper (kun læse, granulært samtykke — jf. PRD F1):**
- `stepCount`, `distanceWalkingRunning`, `flightsClimbed`, `appleExerciseTime`, `heartRate` (sidstnævnte til fase 2).

**Forespørgsler:**
- **Dagens tal:** `HKStatisticsQuery` (sum) for i dag.
- **Uge/historik & rekorder:** `HKStatisticsCollectionQuery` med dags-intervaller → beregn "bedste uge/dag" lokalt.
- **Passiv opdatering:** `HKObserverQuery` + `enableBackgroundDelivery` så Today opdateres uden at brugeren åbner appen.

**Auth-flow:** kun ved onboarding-trin "Connect Health", med ærlig forklaring *før* systemets dialog. Appen virker (manuelt mål) selv hvis brugeren afviser — graceful degradation.

**Info.plist:** `NSHealthShareUsageDescription` (klar, ærlig tekst). Aktivér HealthKit-capability + background delivery.

---

## 4. Datalag & "konkurrér mod dig selv"

- **Mål, units, notif-prefs, rekorder-cache** ligger i SwiftData (on-device).
- **Skridtdata persisteres ikke** af os — vi læser live fra HealthKit (kilden), og cacher kun afledte rekorder for hurtig visning.
- **Personlige rekorder** (bedste dag/uge, nuværende streak) beregnes fra `HKStatisticsCollectionQuery` og opdateres når ny data kommer ind. Ingen sammenligning med andre → ingen brugere, ingen database, ingen GDPR-byrde.

---

## 5. Notifikationer (lokale)

- **Anti-stillesiddende / exercise-snack:** tjek seneste aktivitet via HealthKit; hvis stillesiddende > tærskel i aktivt tidsrum → venlig lokal notifikation ("Take the stairs?"). Maks 1–2/dag, helt styrbart i Settings.
- Ingen push-server. Alt planlægges lokalt med `UNUserNotificationCenter`.

---

## 6. Design-system-integration

1. Tilføj IAMJARL som SPM-dependency.
2. `WalkfulTheme.swift` mapper IAMJARL-tokens til SwiftUI: `Color`, spacing-konstanter, radius, motion-kurver. Light = lilla `#A435D2`, dark = lime `#D0FF00` — drevet af `colorScheme`.
3. **Regel fra IAMJARL:** ingen hardcodede farve-/spacing-værdier i views — kun tokens. Fuld light+dark fra dag 1.

---

## 7. Build-rækkefølge (milestones)

| # | Milestone | Indhold |
|---|-----------|---------|
| **M0** | Skelet | Xcode-projekt, IAMJARL SPM, WalkfulTheme, light/dark, navigation |
| **M1** | Health → skærm | HealthKit-auth + dagens skridt → Today-ring (kerne-loop synligt) |
| **M2** | Onboarding + mål | Flow: velkomst → Health → mål (~7.000, ærlig ramme) → notif-prefs; persistér i SwiftData |
| **M3** | Uge + rekorder | `StatisticsCollectionQuery`, dig-vs-din-bedste, streaks |
| **M4** | Nudges | Lokale exercise-snack/anti-stillesiddende notifikationer + Settings-styring |
| **M5** | Polish + release | Tilgængelighed, lokalisering (en), tom-tilstande, App Store-materiale |
| **Fase 2** | Watch + mere | watchOS-app/komplikation, intervalgang-coach (`HKWorkoutSession`), humør-check-in |

---

## 8. Privacy & App Store

- **App Privacy "Nutrition Label":** "Data Not Collected" — sandt, fordi intet forlader enheden.
- HealthKit-data må **ikke** bruges til reklame/markedsføring (Apple-krav) — ikke relevant for os, men værd at bekræfte ved review.
- Engangskøb via StoreKit 2 (ingen abonnement, ingen reklamer).

---

## 9. Beslutninger taget (let at ændre)
- Min. iOS 18 · SwiftData til struktureret lokal data · skridt læses live (ikke kopieret) · ingen watchOS-app i MVP (Watch-data kommer via HealthKit).

## 10. Åbne tekniske spørgsmål
- **Verificér iOS 26 / WWDC25-detaljer** (native iPhone-workouts til intervalgang-coach) mod shipping-SDK før fase 2.
- Tærskler for "stillesiddende"-nudge — kalibreres i M4.
- Skal streaks være helt skånsomme (ingen tab ved misset dag)? → produktbeslutning før M3.
