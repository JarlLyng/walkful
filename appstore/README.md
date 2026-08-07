# App Store screenshots

Posters for the App Store listing, built with the portfolio standard in the private hub
(`DESIGN.md` → "App Store screenshots", implemented by `tools/appstore_screenshots.py`).
Capture happens here, composition happens there, so every IAMJARL app shares one look.

## Layout

- `raw/` — unretouched simulator captures, `<locale>-<screen>.png`
- `manifest.json` — what gets composed: shot order, captions per locale, slot sizes
- `1.1.0/` — the composed posters, one folder per locale (`en/`, `da/`)

Superseded release folders are deleted rather than kept. Git history has them.

## Walkful's settings

From the per-app table in `DESIGN.md`, so nobody re-derives them:

| Setting | Value | Why |
|---|---|---|
| Mode | `light` | The positioning is calm and anti-streak-guilt. A near-black ground with a neon lime accent would contradict the product. |
| Accent | `#A435D2` | The light-mode primary, fetched from `iamjarl-design`, never hardcoded. |

The device screens inside the posters are captured in **dark** appearance. That is a deliberate
mix: the standard governs the poster ground and the accent, and a dark screen on a light ground
reads well and is a common store pattern. Light captures would be the fully coherent version and
are a candidate improvement.

## Shot order

Ordered by proof then objection, per `DESIGN.md`, not as a feature tour:

1. **Today** — the wedge: steps paired with what they mean, on an evidence-based goal.
2. **Pro / pay-once** — removes the biggest objection for a paid app: one payment, no subscription, no accounts.
3. **Insights** — the year heatmap. The one visual that made strangers on r/walking ask what the app was.
4. **Widgets** — a real Home Screen with both widgets on it, not a mockup.
5. **Interval coach** — the Pro fitness feature, with the "no running" reassurance.

## Rebuilding the set

From the repo root, with the hub cloned alongside and Pillow installed in `.venv`:

```bash
.venv/bin/python <hub>/tools/appstore_screenshots.py batch appstore/manifest.json
```

Re-capturing the raws needs the app's screenshot mode. Two things to know:

- **`xcrun simctl ui <udid> appearance` gets reset** by a SpringBoard restart or a simulator
  reboot. Re-assert it and verify a captured pixel rather than trusting the setting.
- **Widget language follows the device, not launch arguments.** Set it with
  `xcrun simctl spawn <udid> defaults write -g AppleLanguages -array da`, restart SpringBoard,
  then relaunch the app once so the widget timeline refreshes.

## Uploading

App Store Connect validates per slot: `iphone-6.9-*.png` (1290×2796) belongs in the 6.9" slot,
`iphone-6.5-*.png` (1242×2688) in the 6.5" one. Uploading the wrong size to a slot is what the
"dimensions of one or more screenshots are wrong" error means. `da/` goes under the Danish
localization on the version page.

**You only need one iPhone set.** Apple scales whichever you supply to the other sizes, so both
slots exist here only because the listing's legacy slot was 6.5". 6.9" is the better single
choice (Apple downscales it cleanly, and it is the size new listings are asked for), so when the
6.5" set in App Store Connect is retired, drop the 6.5" entries from the manifest too.
