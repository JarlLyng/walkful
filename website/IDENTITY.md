# Site identity

Six decisions about how walkful.iamjarl.com looks, made on purpose rather than
inherited. The strategy hub holds the same table for every site in the portfolio.

| Decision | Walkful |
|---|---|
| **Ground** | Light, pinned. Calm and daytime. |
| **Accent** | Purple, `#A435D2`, as the App Store posters and listing use. |
| **Type voice** | Outfit for display, Inter for copy. |
| **Imagery mode** | The product screen first, then the step slider. |
| **Motion** | The step slider is the one element that responds to the visitor. Copy is never hidden behind motion. |
| **Signature** | The step slider. Keep it as it is. |

## Why light is pinned

Until September 2026 the site followed the visitor's colour scheme and so had two
identities: white with a purple accent, or near-black with a lime one. Both looked
fine. They did not look like the same product, and the App Store posters had already
chosen light in August.

A visitor in dark mode now gets a light marketing page, which is ordinary. **The app
itself keeps both modes**; this is about the site only.

## How it is enforced

- No `prefers-color-scheme: dark` rule anywhere in `website/`.
- `color-scheme: light` on the root of every page, so form controls, scrollbars and
  system colours stay light too.
- One `theme-color`, `#A435D2`.
- **The footer component has to be pinned separately.** `<ij-footer>` follows the OS
  colour scheme unless the host sets its `--ij-*` tokens. Each stylesheet sets four of
  them on `ij-footer`, to the component's own light values. Remove that rule and a
  dark-mode visitor gets white footer text on a white page.

If a future change reintroduces a dark rule, the pin is the thing to check first.

## The social card

`og-image.png` is the image a stranger sees first, when a link is shared anywhere, before any
word of the page. Per the hub's `DESIGN.md` it does two jobs: the site's `og:image` on every page,
and the repo's GitHub social preview.

It carries the name, one line of outcome, and the real Today screen, on the pinned light ground
with the purple accent. It replaced an enlarged app icon on a flat ground, which the hub measured
on 2026-09-22 as saying nothing about what the app does.

Generated, not drawn by hand: `appstore/social/make_card.py` builds it from
`appstore/social/today-en.png` with the App Store poster tool's own helpers, so it shares the
posters' look. **Recapture that screenshot whenever the Today screen's copy changes.** The card is
public imagery, and an old capture advertises old copy; the first draft of this card showed an
em-dash the app had already dropped, because it used an August capture.

**The GitHub half is a manual upload.** Repo Settings, then Social preview. There is no API for it.

