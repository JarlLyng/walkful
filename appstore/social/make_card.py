# Social card for Walkful: og:image and GitHub social preview, per the hub's
# DESIGN.md "Social cards". On the site's identity since the redesign (#200):
# warm sand, charcoal, the icon's magenta, Fraunces soft for the words that
# carry the voice. Reuses the App Store poster tool's bezel and shadow, so the
# phone matches the posters; the bezel is generic, with no island.
#
# Usage, from the repo root with the hub and iamjarl-design cloned alongside:
#   /usr/bin/python3 appstore/social/make_card.py appstore/social/today-en.png website/og-image.png
#
# today-en.png is the site-mode capture (appstore/site/README.md). Recapture it
# whenever the Today screen's copy changes: the card is public imagery, and an
# old capture advertises old copy.
import os, sys, importlib.util
from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
spec = importlib.util.spec_from_file_location(
    "posters", os.path.join(HERE, "..", "..", "..", "iamjarl-strategy", "tools", "appstore_screenshots.py"))
P = importlib.util.module_from_spec(spec); spec.loader.exec_module(P)
FRAUNCES = os.path.join(HERE, "..", "..", "..", "iamjarl-design", "fonts", "fraunces-latin-soft-normal.woff2")

# Walkful's identity, from iamjarl-design's identity/walkful.css (v1.22.0).
SAND = P.hex_to_rgb("#F5EFE6")
CHARCOAL = P.hex_to_rgb("#2B2825")
SECONDARY = P.hex_to_rgb("#53504C")
MAGENTA = P.hex_to_rgb("#F140FE")       # strokes only, never small text
LINK = P.hex_to_rgb("#A80FB3")          # the text-safe accent

def fraunces(size, weight=400):
    f = ImageFont.truetype(FRAUNCES, size)
    f.set_variation_by_axes([weight, 100])  # Weight, Softness: soft, as the site sets it
    return f

W, H = 1200, 630
M = 72                                   # keep text well away from every edge
bg = Image.new("RGBA", (W, H), SAND + (255,))

# --- the product: Today, in a generic bezel, bleeding off the bottom edge ---
shot = Image.open(sys.argv[1]).convert("RGB")
target_w = 330
shot = shot.resize((target_w, int(shot.height * target_w / shot.width)), Image.LANCZOS)
phone = P.bezel(shot)
layer, (px, py) = P.with_shadow(phone, blur=26, offset=14, opacity=48)
phone_x = W - M - phone.width + 8
phone_y = 64
bg.alpha_composite(layer, (phone_x - px, phone_y - py))

# --- the words ---------------------------------------------------------------
d = ImageDraw.Draw(bg)
col_w = phone_x - M - 56

d.text((M, 104), "Walkful", font=fraunces(84), fill=CHARCOAL)

head_f = fraunces(56)
d.text((M, 222), "Every step counts.", font=head_f, fill=CHARCOAL)

# The hero's loose magenta line under the headline, as on the page.
line_y = 304
pts = [(M + 2 + i * 6, line_y + 5 * __import__("math").sin(i / 7.0)) for i in range(0, 74)]
d.line(pts, fill=MAGENTA, width=5, joint="curve")

facts_f = P.font(26, "Regular")
y = 346
for line in P.wrap(d, "A calm, private step tracker for iPhone. It all stays on your phone, and nothing scolds you for a quiet day.", facts_f, col_w):
    d.text((M, y), line, font=facts_f, fill=SECONDARY)
    y += 38

d.text((M, H - M - 30), "walkful.iamjarl.com", font=P.font(25, "Semibold"), fill=LINK)

out = sys.argv[2]
bg.convert("RGB").save(out, "PNG", optimize=True)
print("wrote", out, bg.size)
