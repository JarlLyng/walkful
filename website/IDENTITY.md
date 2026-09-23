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
