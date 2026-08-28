#!/usr/bin/env python3
"""Emit the Deep Reef background sources as HTML, for rendering to PNG.

Usage:  python3 generate-backgrounds.py [out-dir]
Then:   see render-backgrounds.sh, which screenshots them at 3840x2160.
"""
import random, pathlib, sys

OUT = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else "backgrounds-src")
OUT.mkdir(parents=True, exist_ok=True)

# Deep Reef palette
AQUA   = "#17e0c8"
OCEAN  = "#0aa3e8"
TEAL   = "#10a3ab"
MID    = "#0b6a86"
DEEP   = "#093f63"
ABYSS  = "#05203c"
NIGHT  = "#02141c"
CORAL  = "#ff7a5c"
PINK   = "#ff5fa2"
SUN    = "#ffc93c"

VARIANTS = [
    # name, base gradient, glow, shaft opacity, shaft angle, bubble count/scale, extra overlay, caustic opacity, vignette
    dict(name="1-deep-reef",
         base=f"radial-gradient(140% 110% at 18% -8%, #1fd6c0 0%, {TEAL} 17%, {MID} 39%, {DEEP} 64%, {ABYSS} 100%)",
         glow=f"radial-gradient(60% 45% at 20% 4%, rgba(120,255,238,.45) 0%, rgba(120,255,238,0) 62%)",
         shaft=.20, angle=118, bubbles=22, bscale=1.0, caustic=.22, vig=.55,
         extra=""),
    dict(name="2-bubble-drift",
         base=f"radial-gradient(120% 130% at 72% -14%, {TEAL} 0%, {MID} 26%, {DEEP} 56%, {ABYSS} 88%, {NIGHT} 100%)",
         glow=f"radial-gradient(50% 60% at 74% 0%, rgba(90,240,255,.42) 0%, rgba(90,240,255,0) 60%)",
         shaft=.16, angle=64, bubbles=46, bscale=1.35, caustic=.14, vig=.60,
         extra=""),
    dict(name="3-caustics",
         base=f"linear-gradient(176deg, #2fe3d0 0%, {TEAL} 14%, {MID} 38%, {DEEP} 68%, {ABYSS} 100%)",
         glow=f"radial-gradient(90% 40% at 50% -6%, rgba(190,255,250,.55) 0%, rgba(190,255,250,0) 58%)",
         shaft=.30, angle=96, bubbles=14, bscale=.8, caustic=.55, vig=.50,
         extra=""),
    dict(name="4-thermocline",
         base=(f"linear-gradient(179deg, #35ded0 0%, {TEAL} 16%, {MID} 40%, "
               f"{DEEP} 66%, {ABYSS} 88%, {NIGHT} 100%)"),
         glow=f"radial-gradient(85% 55% at 34% -4%, rgba(150,255,242,.42) 0%, rgba(150,255,242,0) 68%)",
         shaft=.12, angle=104, bubbles=9, bscale=.75, caustic=.08, vig=.40,
         extra=""),
    dict(name="5-anemone",
         base=f"radial-gradient(130% 120% at 82% 88%, {PINK} 0%, {CORAL} 9%, {MID} 34%, {DEEP} 60%, {ABYSS} 100%)",
         glow=f"radial-gradient(45% 40% at 84% 90%, rgba(255,140,190,.50) 0%, rgba(255,140,190,0) 62%)",
         shaft=.18, angle=132, bubbles=28, bscale=1.1, caustic=.18, vig=.58,
         extra=""),
    dict(name="6-abyss",
         base=f"radial-gradient(105% 95% at 50% 112%, #1ec4c0 0%, {MID} 22%, {DEEP} 48%, {ABYSS} 74%, {NIGHT} 100%)",
         glow=f"radial-gradient(58% 44% at 50% 100%, rgba(40,235,215,.60) 0%, rgba(40,235,215,0) 68%)",
         shaft=.10, angle=90, bubbles=14, bscale=1.0, caustic=.10, vig=.22,
         extra=""),
]

def bubbles(n, scale, seed):
    rnd = random.Random(seed)
    out = []
    for _ in range(n):
        d = rnd.uniform(1.1, 13.0) * scale          # % of width
        x = rnd.uniform(-4, 100)
        y = rnd.uniform(-4, 100)
        o = rnd.uniform(.30, .95)
        blur = "filter:blur(%.1fpx);" % rnd.uniform(0, 5) if rnd.random() < .35 else ""
        out.append(
            f'<span class="bub" style="width:{d:.2f}%;left:{x:.2f}%;top:{y:.2f}%;'
            f'opacity:{o:.2f};{blur}"></span>')
    return "\n".join(out)

TPL = """<!doctype html><html><head><meta charset="utf-8"><style>
*{margin:0;padding:0;box-sizing:border-box}
html,body{width:3840px;height:2160px;overflow:hidden;background:#02141c}
.stage{position:relative;width:3840px;height:2160px;overflow:hidden}
.base{position:absolute;inset:0;background:__BASE__;__EXTRA__}
.glow{position:absolute;inset:0;background:__GLOW__;mix-blend-mode:screen}
.shafts{position:absolute;inset:-25%;mix-blend-mode:screen;opacity:__SHAFT__;
  background:
    linear-gradient(__ANGLE__deg, transparent 18%, rgba(210,255,255,.85) 24%, transparent 30%),
    linear-gradient(__ANGLE__deg, transparent 36%, rgba(210,255,255,.55) 41%, transparent 47%),
    linear-gradient(__ANGLE__deg, transparent 55%, rgba(210,255,255,.70) 61%, transparent 67%),
    linear-gradient(__ANGLE__deg, transparent 74%, rgba(210,255,255,.40) 79%, transparent 85%);
  filter:blur(28px)}
.caustics{position:absolute;inset:-10%;mix-blend-mode:screen;opacity:__CAUSTIC__}
.bub{position:absolute;aspect-ratio:1;border-radius:50%;
  background:
    radial-gradient(circle at 32% 25%, rgba(255,255,255,.95) 0%, rgba(255,255,255,.34) 11%, rgba(255,255,255,.05) 34%, rgba(255,255,255,0) 58%),
    radial-gradient(circle at 70% 80%, rgba(120,245,230,.42) 0%, rgba(120,245,230,0) 55%),
    radial-gradient(circle at 50% 50%, rgba(255,255,255,.03) 60%, rgba(255,255,255,.16) 88%, rgba(255,255,255,0) 100%);
  box-shadow:inset 0 0 40px rgba(255,255,255,.22), 0 0 60px rgba(60,230,215,.20);
  border:1px solid rgba(255,255,255,.22)}
.vig{position:absolute;inset:0;opacity:__VIG__;
  background:radial-gradient(115% 105% at 50% 42%, rgba(0,0,0,0) 42%, rgba(1,10,16,.85) 100%)}
</style></head><body><div class="stage">
<div class="base"></div>
<div class="glow"></div>
<svg class="caustics" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <filter id="cau" x="0" y="0" width="100%" height="100%">
      <feTurbulence type="fractalNoise" baseFrequency="0.0016 0.0042" numOctaves="4" seed="__SEED__" result="n"/>
      <feColorMatrix in="n" type="matrix" result="m"
        values="0 0 0 0 0.55  0 0 0 0 1  0 0 0 0 0.96  0 0 0 -2.4 1.25"/>
      <feGaussianBlur in="m" stdDeviation="5"/>
    </filter>
  </defs>
  <rect width="100%" height="100%" filter="url(#cau)"/>
</svg>
<div class="shafts"></div>
__BUBBLES__
<div class="vig"></div>
</div></body></html>"""

for i, v in enumerate(VARIANTS):
    html = (TPL
        .replace("__BASE__", v["base"])
        .replace("__GLOW__", v["glow"])
        .replace("__EXTRA__", v["extra"])
        .replace("__SHAFT__", str(v["shaft"]))
        .replace("__ANGLE__", str(v["angle"]))
        .replace("__CAUSTIC__", str(v["caustic"]))
        .replace("__VIG__", str(v["vig"]))
        .replace("__SEED__", str(7 + i * 13))
        .replace("__BUBBLES__", bubbles(v["bubbles"], v["bscale"], 1000 + i)))
    (OUT / f'{v["name"]}.html').write_text(html)
    print("wrote", v["name"] + ".html")
