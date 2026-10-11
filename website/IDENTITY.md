# Site identity

Six decisions about how walkful.iamjarl.com looks, made on purpose rather than
inherited. The strategy hub holds the same table for every site in the portfolio.

Since 2026-10-11 Walkful is the flagship of the portfolio's new site design: each app
gets its own personality, built on the design system's marketing kit (#200). The
reasoning is in the hub's private brief, `Walkful/site-brief.md`.

| Decision | Walkful |
|---|---|
| **Ground** | Warm sand, light only. An outdoor morning: unhurried, and nothing judges you. |
| **Accent** | Magenta, `#F140FE` from the icon, for drawn strokes and fills. A deeper `#A80FB3` for links and any text, where the bright one would not read. |
| **Type voice** | Fraunces, soft (`'SOFT' 100`), for headlines. The system's UI face for copy, at 18 px or more. |
| **Imagery mode** | Loose line drawings on one theme, paths and trees, one per statement. Then the app itself, in a plain generic phone. |
| **Motion** | Two things move: the hero's screen recording and the phone that stays on screen. Both stop under reduce motion. |
| **Signature** | The walked path, the one magenta line in every drawing. |

The step slider, the old signature, is gone with the redesign. The page the owner set out in
#200 has no place for it.

## How it is enforced

- **Everything comes from one design-system release,** `@v1.22.0`, with SRI: the tokens,
  Walkful's identity sheet, the Fraunces face, the kit, `<ij-nav>` and `<ij-footer>`. Bump
  them together, never one by one.
- **The identity sheet holds the page light** whatever the visitor's setting, so there is no
  `prefers-color-scheme` rule in `website/` and no `class="light"` to keep. With the system
  in dark mode, the page is still sand.
- **The page's own names point at the identity.** `learn.css` and the support and privacy
  pages keep their short variable names (`--bg`, `--text`) but set them from the `--ij-*`
  tokens, so the colours live in one place.
- One `theme-color`, the sand, `#F5EFE6`.
- **Wherever the display face is set by hand, its soft axis goes with it:**
  `font-variation-settings: var(--ij-font-display-axes, normal)`. Without it Fraunces is the
  sharp cut.
- **The first screen never waits for a script.** All text is in the served HTML, the loop
  shows its poster until it plays, and the tour is a row of screens until `kit.js` makes it
  live.

## The drawings

Generated with AI and finished by the owner in Figma, then exported as SVG. Until they land,
the statements carry the kit's placeholder drawings.

When the real ones go in, the footer gets the credit line "Illustrations drawn with AI and
finished by Jarl" and the Made by Human "Co-created with AI" badge. They are never presented
as hand-drawn.

## The loop and the screens

The hero's Today loop and the tour's screens come from the app's Debug site mode on an iPhone 17
Pro simulator. How to make them again is in `appstore/site/README.md`. **Remake them whenever
those screens change.**

## The social card

`og-image.png` is the image a stranger sees first, when a link is shared anywhere, before any
word of the page. Per the hub's `DESIGN.md` it does two jobs: the site's `og:image` on every page,
and the repo's GitHub social preview.

**It still has the old identity:** white with the purple accent, from September. It should be
remade on sand with the new face before the redesign ships, from the same `-site` capture, and
uploaded to GitHub again.

Generated, not drawn by hand: `appstore/social/make_card.py` builds it from
`appstore/social/today-en.png` with the App Store poster tool's own helpers, so it shares the
posters' look. **Recapture that screenshot whenever the Today screen's copy changes.** The card is
public imagery, and an old capture advertises old copy; the first draft of this card showed an
em-dash the app had already dropped, because it used an August capture.

**The GitHub half is a manual upload.** Repo Settings, then Social preview. There is no API for it.
