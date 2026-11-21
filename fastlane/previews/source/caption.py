"""caption.py <text> <top|center|bottom> <out.png> — full-frame 886x1920 transparent caption pill."""
import sys
from PIL import Image, ImageDraw, ImageFont

W, H = 886, 1920
text, pos, out = sys.argv[1], sys.argv[2], sys.argv[3]
# AppleSDGothicNeo.ttc face 6 = Bold (covers Hangul + Latin)
font = ImageFont.truetype("/System/Library/Fonts/AppleSDGothicNeo.ttc", 50, index=6)

img = Image.new("RGBA", (W, H), (0, 0, 0, 0))
d = ImageDraw.Draw(img)
l, t, r, b = d.textbbox((0, 0), text, font=font)
tw, th = r - l, b - t
padx, pady = 34, 24
bw, bh = tw + padx * 2, th + pady * 2
x = (W - bw) // 2
y = {"top": 420, "center": (H - bh) // 2}.get(pos, H - bh - 330)
d.rounded_rectangle((x, y, x + bw, y + bh), radius=bh // 2, fill=(0, 0, 0, 178))
d.text((x + padx - l, y + pady - t), text, font=font, fill=(255, 255, 255, 255))
img.save(out)
