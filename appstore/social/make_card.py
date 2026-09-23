# Social card for Walkful: og:image and GitHub social preview, per the hub's
# DESIGN.md "Social cards" (2026-09-22). Reuses the App Store poster tool's own
# building blocks so the card shares the posters' look.
#
# Usage, from the repo root with the hub cloned alongside:
#   .venv/bin/python appstore/social/make_card.py appstore/social/today-en.png website/og-image.png
#
# Recapture today-en.png from the current build whenever the Today screen's copy changes:
# the card is public imagery, and an old capture advertises old copy.
import os, sys, importlib.util
from PIL import Image, ImageDraw

spec = importlib.util.spec_from_file_location(
    "posters", os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "..", "iamjarl-strategy", "tools", "appstore_screenshots.py"))
P = importlib.util.module_from_spec(spec); spec.loader.exec_module(P)

W, H = 1200, 630
M = 72                                   # keep text well away from every edge
ACCENT = P.hex_to_rgb("#A435D2")         # the site's pinned light accent (#171)
ground = P.GROUNDS["light"]
TEXT = ground["text"]

bg = P.vgradient(W, H, ground)
bg = P.decor(bg, ACCENT, "light").convert("RGBA")

# --- the product: Today, in a bezel, bleeding off the bottom edge ------------
shot = Image.open(sys.argv[1]).convert("RGB")
target_w = 330
shot = shot.resize((target_w, int(shot.height * target_w / shot.width)), Image.LANCZOS)
phone = P.bezel(shot)
layer, (px, py) = P.with_shadow(phone, blur=26, offset=14, opacity=70)
phone_x = W - M - phone.width + 8
phone_y = 64
bg.alpha_composite(layer, (phone_x - px, phone_y - py))

# --- the words -------------------------------------------------------------
d = ImageDraw.Draw(bg)
col_w = phone_x - M - 56

name_f = P.font(76, "Bold")
d.text((M, 118), "Walkful", font=name_f, fill=TEXT)

out_f = P.font(46, "Semibold")
y = 222
# Break where the App Store poster breaks, after the comma, never on "count."
for line in ("Steps with meaning,", "not just a count."):
    d.text((M, y), line, font=out_f, fill=TEXT)
    y += 58

facts_f = P.font(25, "Regular")
facts_rgb = tuple(int(c * 0.72 + 250 * 0.28) for c in TEXT)
y += 30
for line in P.wrap(d, "Free for iPhone. Private by design: nothing leaves your phone.", facts_f, col_w):
    d.text((M, y), line, font=facts_f, fill=facts_rgb)
    y += 36

url_f = P.font(25, "Semibold")
d.text((M, H - M - 30), "walkful.iamjarl.com", font=url_f, fill=ACCENT)

out = sys.argv[2]
bg.convert("RGB").save(out, "PNG", optimize=True)
print("skrev", out, bg.size)
