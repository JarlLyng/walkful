# Social card for Walkful: og:image and GitHub social preview. On the site's
# identity since the redesign (#200): warm sand, charcoal, Fraunces soft for the
# words that carry the voice. No underline: on the site the walked path is the
# one magenta line (#207). The phone sits in a plain drawn bezel, with no island.
#
# Self-contained: it needs Pillow and macOS's system font, nothing outside this
# repo. Fraunces comes from the design system's copy the site already serves.
#
# Usage, from the repo root:
#   /usr/bin/python3 appstore/social/make_card.py appstore/social/today-en.png website/og-image.png
#
# today-en.png is the site-mode capture (appstore/site/README.md). Recapture it
# whenever the Today screen's copy changes: the card is public imagery, and an
# old capture advertises old copy.
import glob, os, sys
from PIL import Image, ImageDraw, ImageFilter, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
SFNS = "/System/Library/Fonts/SFNS.ttf"
# The newest design-system copy under website/assets wins, so a bump needs no edit here.
FRAUNCES = sorted(glob.glob(os.path.join(HERE, "..", "..", "website", "assets",
                                         "iamjarl-design@*", "fonts", "fraunces-latin-soft-normal.woff2")))[-1]


def hex_to_rgb(h):
    h = h.strip().lstrip("#")
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))


def font(size, weight="Bold"):
    """The system UI face at a named weight."""
    f = ImageFont.truetype(SFNS, size)
    try:
        f.set_variation_by_name(weight)
    except Exception:
        pass
    return f


def fraunces(size, weight=400):
    f = ImageFont.truetype(FRAUNCES, size)
    f.set_variation_by_axes([weight, 100])  # Weight, Softness: soft, as the site sets it
    return f


def wrap(draw, text, fnt, max_w):
    lines, cur = [], ""
    for word in text.split(" "):
        trial = (cur + " " + word).strip()
        if draw.textlength(trial, font=fnt) <= max_w or not cur:
            cur = trial
        else:
            lines.append(cur)
            cur = word
    lines.append(cur)
    return lines


def rounded(img, radius):
    mask = Image.new("L", img.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, *img.size], radius=radius, fill=255)
    out = Image.new("RGBA", img.size, (0, 0, 0, 0))
    out.paste(img, (0, 0))
    out.putalpha(mask)
    return out


def bezel(shot):
    """A drawn device bezel: a black border with a real device's corner radii."""
    w, h = shot.size
    b = max(6, int(min(w, h) * 0.028))
    inner_r = int(min(w, h) * 0.055)
    outer_r = inner_r + b
    out = Image.new("RGBA", (w + b * 2, h + b * 2), (0, 0, 0, 0))
    d = ImageDraw.Draw(out)
    d.rounded_rectangle([0, 0, out.width - 1, out.height - 1], radius=outer_r, fill=(12, 12, 14, 255))
    d.rounded_rectangle([0, 0, out.width - 1, out.height - 1], radius=outer_r, outline=(72, 72, 78, 255),
                        width=max(2, b // 6))
    out.alpha_composite(rounded(shot, inner_r), (b, b))
    return out


def with_shadow(shot, blur, offset, opacity):
    """The shot over a soft drop shadow, and where to paste it."""
    pad = blur * 3
    layer = Image.new("RGBA", (shot.size[0] + pad * 2, shot.size[1] + pad * 2), (0, 0, 0, 0))
    shadow = Image.new("RGBA", layer.size, (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle(
        [pad, pad + offset, pad + shot.size[0], pad + offset + shot.size[1]],
        radius=int(min(shot.size) * 0.05), fill=(0, 0, 0, opacity))
    layer.alpha_composite(shadow.filter(ImageFilter.GaussianBlur(blur)))
    layer.alpha_composite(shot.convert("RGBA"), (pad, pad))
    return layer, (pad, pad)


# Walkful's identity, as the design system's identity/walkful.css sets it.
SAND = hex_to_rgb("#F5EFE6")
CHARCOAL = hex_to_rgb("#2B2825")
SECONDARY = hex_to_rgb("#53504C")
LINK = hex_to_rgb("#A80FB3")          # the text-safe accent

W, H = 1200, 630
M = 72                                   # keep text well away from every edge
bg = Image.new("RGBA", (W, H), SAND + (255,))

# --- the product: Today, in a plain bezel, bleeding off the bottom edge -------
shot = Image.open(sys.argv[1]).convert("RGB")
target_w = 330
shot = shot.resize((target_w, int(shot.height * target_w / shot.width)), Image.LANCZOS)
phone = bezel(shot)
layer, (px, py) = with_shadow(phone, blur=26, offset=14, opacity=48)
phone_x = W - M - phone.width + 8
phone_y = 64
bg.alpha_composite(layer, (phone_x - px, phone_y - py))

# --- the words ---------------------------------------------------------------
d = ImageDraw.Draw(bg)
col_w = phone_x - M - 56

d.text((M, 104), "Walkful", font=fraunces(84), fill=CHARCOAL)
d.text((M, 222), "Every step counts.", font=fraunces(56), fill=CHARCOAL)

facts_f = font(26, "Regular")
y = 330
for line in wrap(d, "A calm, private step tracker for iPhone. It all stays on your phone, and nothing scolds you for a quiet day.", facts_f, col_w):
    d.text((M, y), line, font=facts_f, fill=SECONDARY)
    y += 38

d.text((M, H - M - 30), "walkful.iamjarl.com", font=font(25, "Semibold"), fill=LINK)

out = sys.argv[2]
bg.convert("RGB").save(out, "PNG", optimize=True)
print("wrote", out, bg.size)
