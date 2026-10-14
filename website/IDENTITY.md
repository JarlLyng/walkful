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
| **Imagery mode** | Two photographs of paths through trees, monochrome and dimmed toward the sand: a band after the statements, and behind the closing wordmark. Then the app itself, in a plain generic phone. |
| **Motion** | Two things move: the hero's screen recording and the phone that stays on screen. Both stop under reduce motion. |
| **Signature** | The walked path, drawn as the one magenta line on the first photograph. |

The step slider, the old signature, is gone with the redesign. The page the owner set out in
#200 has no place for it.

## How it is enforced

- **Everything comes from one design-system release,** `@v1.31.0`, with SRI: the tokens,
  Walkful's identity sheet, the Fraunces face, the kit, `<ij-nav>` and `<ij-footer>`. Bump
  them together, never one by one.
  **One exception for now (#210):** `ij-footer.js` and `kit.css` are at `@v1.32.1`, for the
  footer's quiet text at AA. jsDelivr answered 503 for uncached v1.32.1 files on 2026-10-15,
  Fraunces' sheet among them, so the rest stays on v1.31.0, which is unchanged for Walkful and
  cached. Move the rest to v1.32.1 once every file there serves 200.
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

## The photographs

Since 2026-10-13, two photographs carry the page's mood (#207), on the kit's `.ij-scene`. They
replaced the kit's placeholder drawings, which didn't hold up, and the magenta underlines under
the headline and the signature went with them.

- **The band,** after the statements: a path worn through grass between trees in fog, by Luca
  Volpe ([ZrQZf1xY8KQ](https://unsplash.com/photos/ZrQZf1xY8KQ)). Its walked path is the one
  magenta line, `dist/scenes/walkful/path-in-fog.svg` from iamjarl-design, inlined right after
  the photo. The line crops exactly as the photo does, so the photo stays centred.
- **Behind the closing wordmark:** a narrow worn path under large trees, by zhao sky
  ([6KCyb6eoWmY](https://unsplash.com/photos/6KCyb6eoWmY)).

Both are free under the Unsplash License, with no faces and no brands. They are self-hosted in
`assets/site/` at 960, 1280 and 1920 px as WebP. They come pre-desaturated, since the kit shows
them monochrome anyway, which keeps the files light. Both load lazily with `alt=""`, never in the
hero, and nothing moves. The footer credits the photographers.

Nothing on the page is an AI illustration any more, so the "drawn with AI" credit is gone.

**No Made by Human badge on the site.** The hub's `PROJECT_STANDARDS.md` keeps the "Co-created
with AI" badge to the repo's README, never a marketing site. It shipped in the footer for a day
and came out again (2026-10-11).

## The loop and the screens

The hero's Today loop and the tour's screens come from the app's Debug site mode on an iPhone 17
Pro simulator. How to make them again is in `appstore/site/README.md`. **Remake them whenever
those screens change.**

## The social card

`og-image.png` is the image a stranger sees first, when a link is shared anywhere, before any
word of the page. Per the hub's `DESIGN.md` it does two jobs: the site's `og:image` on every page,
and the repo's GitHub social preview.

It carries the name and "Every step counts." in Fraunces soft, one line of outcome, and the
real Today screen in a generic phone, on sand. No underline: the walked path is the site's one
magenta line. It moved to this
identity with the redesign.

Generated, not drawn by hand: `appstore/social/make_card.py` builds it from
`appstore/social/today-en.png`, the site-mode capture, with the App Store poster tool's bezel and
shadow, and Fraunces from iamjarl-design. **Recapture that screenshot whenever the Today screen's copy changes.** The card is
public imagery, and an old capture advertises old copy; the first draft of this card showed an
em-dash the app had already dropped, because it used an August capture.

**The GitHub half is a manual upload.** Repo Settings, then Social preview. There is no API for it.
