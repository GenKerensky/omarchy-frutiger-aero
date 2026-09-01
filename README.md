# Frutiger Aero for Omarchy

A Frutiger Aero theme for [Omarchy](https://omarchy.org/) — the glass-and-water
look of 2004–2013, in the *Deep Reef* direction: looking down into the water
rather than up at the sky. Aquamarine and deep teal, with coral, sunfish yellow
and anemone pink carrying the ANSI colours.

![The bar](docs/bar.png)

It is more than a palette. Omarchy's shell is Quickshell, which means QML, which
means the bar can do things a colour scheme cannot — real gradients, a specular
cap, a moulded break line. So the bar is glossy, the workspaces are little
screens, and the menu button is a Windows XP Media Center start button.

![Backgrounds](docs/backgrounds.png)

## Status

Work in progress. Not yet listed on the [omarchy.org theme gallery](https://omarchy.org/themes/).

## What's here

`omarchy theme install` clones the repo **straight into**
`~/.config/omarchy/themes/frutiger-aero/`, so the theme is the repo root.

| path | |
|---|---|
| `colors.toml` | the palette — Omarchy generates all themed app configs from it |
| `shell.toml` | the shell surfaces: bar, menus, notifications, popups, lock |
| `icons.theme` | icon theme mapping |
| `backgrounds/` | four wallpapers |
| `install.sh` / `uninstall.sh` | the extras Omarchy will not run from a cloned theme — see below |
| `plugins/genkerensky.bar/` | the bar, forked to add gloss to the strip itself |
| `plugins/genkerensky.workspaces/` | workspaces as 16:10 gel panels |
| `plugins/genkerensky.aero-menu/` | the XP Media Center menu button |
| `hooks/theme-set.d/` | swaps the Aero bar in and out with the theme |
| `hypr/frutiger-aero.lua` | Hyprland window chrome + shell blur layer rules |
| `tools/` | deploy the theme into the live theme dir |
| `src/` | wallpaper source art — Git LFS, not fetched by default, see below |
| `assets/` | Omarchy's mark as an SVG path |

## Install

```bash
omarchy theme install https://github.com/GenKerensky/omarchy-frutiger-aero
bash ~/.config/omarchy/themes/frutiger-aero/install.sh
omarchy theme set frutiger-aero      # the hook swaps the Aero bar in
```

### Why install.sh exists

Omarchy holds cloned themes to a stricter contract than themes you write by
hand: from a repo-installed theme, **no `.lua` is staged at all** (Hyprland and
Neovim configs run code), terminal configs are denied, and everything else is
treated as colour. In practice:

- `colors.toml` drives everything Omarchy generates — including the 45°
  gradient window borders, which this theme defines under
  `hyprland_active_border` / `hyprland_inactive_border`.
- `shell.toml` ships verbatim and themes every Quickshell surface.
- The rest of the Aero look — squircle rounding, the glow shadow, the vibrancy
  blur, terminal translucency, and the shell layer rules that frost the bar
  and menus — cannot ship in the theme format. `install.sh` puts it at
  `~/.config/hypr/frutiger-aero.lua` and adds one `require` line to your
  `hyprland.lua` (backing both up first). `uninstall.sh` reverses all of it.
- The plugins are copied into `~/.config/omarchy/plugins/` and the theme-set
  hook is installed, so the Aero bar appears with the theme and the stock bar
  returns when you switch away.

### The menu button

The Aero gel button replaces the stock one in the bar, but the stock button
also owns the menu overlay — remove it from the bar without keeping the overlay
loaded and the button would open nothing. So that half is a manual edit to
`~/.config/omarchy/shell.json`, on purpose:

1. In `bar.layout.left`, swap `omarchy.menu` for `genkerensky.aero-menu`.
2. Add `omarchy.menu` to the top-level `plugins` array — the overlay stays
   loaded without its button in the bar. (`omarchy plugin list` still reports
   it as `disabled`; that label tracks bar-widget presence. Confirm it works
   by firing the IPC: `omarchy-shell shell toggle omarchy.menu '{"menu":"root"}'`
   should create an `omarchy-menu` layer.)

## Three things worth knowing

**Blur is the whole effect, and vibrancy is the setting that matters.** The
theme runs blur at `size 10, passes 3` with **`vibrancy 0.40`**, up from the
0.17 default. Vibrancy re-saturates what it blurs, which is exactly what Vista's
composited glass did; without it you get frost, not Aero.

**`~/.config/omarchy/shell.toml` overrides every theme.** Omarchy loads the
theme's `shell.toml` first and yours on top, and *user keys win*. If yours pins
`background-alpha` or `text`, it will flatten this theme's per-surface glass —
and a forced white bar text makes the clock invisible on any light theme. Keep
that file to genuinely machine-level things like `[font] base-size`.

**Keep `~/.config/hypr/looknfeel.lua` minimal.** The installed
`frutiger-aero.lua` owns rounding, shadow and blur tuning; anything your
`looknfeel.lua` sets in `decoration` wins over it. `hypr/looknfeel-snippet.lua`
shows the baseline this theme was designed against.

## Full-screen overlays need a different blur threshold

Blurring shell layers at `ignore_alpha = 0.01` is right for the bar and
notifications, where the only near-transparent pixels are rounded corners that
would otherwise pick up a square halo.

It is wrong for the menu. That is a full-screen layer — a dim scrim covering the
display with the card floating on it — so at 0.01 Hyprland blurs the scrim too
and the entire desktop goes soft behind the menu. The scrims sit at 0.45–0.55
and the cards composite to roughly 0.8, so `hypr/frutiger-aero.lua` splits
the namespaces into two groups at **0.65**: the card frosts, the desktop stays
sharp.

Polkit deliberately stays in the panel group. Obscuring the desktop behind a
password prompt is a focus cue, not a bug.

## Backgrounds

Four finished images, committed as-is. There is no generator; replace them by
hand. Keep a replacement close to `colors.toml` — Hyprland's blur takes its
colour from whatever sits behind the glass, so a background that drifts from the
palette drags every translucent surface with it.

The *blissoom* pair ships at 21:9 (4892×2048) rather than 16:9 on purpose.
Omarchy paints every wallpaper with `Image.PreserveAspectCrop` — scale to fill,
crop the overflow, never letterbox
and never stretch — and the current background is one symlink shared by every
monitor, so there is no per-display variant to choose. One ultrawide file
therefore covers both shapes: on a 16:9 display it fits vertically and trims
about 13% off each side, which costs margin and nothing else. A 16:9 file on an
ultrawide has to crop a third of the height, which cuts into the subject. This
is not configurable — the fill mode is hardcoded in Omarchy's shell.

`3-deep-reef.png` and `4-abyss.png` are still 16:9 (3840×2160) and so lose a
third of their height on an ultrawide. They are abstract enough to survive it,
but that is the reason to redo them at 21:9 rather than a claim that 16:9 is
fine.

The first file in sort order is the default. When the current background is not
already one of the theme's — a fresh install, or switching in from another
theme — Omarchy sorts `backgrounds/` and takes the first, so the numeric
prefixes are the whole mechanism; there is no default-background key to set.
(Re-applying a theme you are *already* on advances to the next background
instead, so use `omarchy theme bg set` to come back to it.)

### Wallpaper attribution

`backgrounds/1-blissoomDark-21x9.png` and `backgrounds/2-blissoomLight-21x9.png`
are extended from **Windows 11 Bliss** by **Left_Hovercraft451**, from the
Internet Archive item
[windows-11-bliss-wallpaper](https://archive.org/details/windows-11-bliss-wallpaper/).
The author describes it as a concept piece folding the Windows XP *Bliss* hill
into the Windows 11 *Bloom* ribbon. The originals are 3072×2048; the files here
are painted out sideways to 21:9, holding the original height. The untouched
downloads and the GIMP files for that work are in `src/`.

The item declares no licence, and the work derives from two Microsoft
wallpapers, so treat it as all rights reserved: it ships here on attribution
alone and is **not** covered by this repo's MIT licence. Delete both files and
`omarchy theme set` falls back to `3-deep-reef.png`.

### Source art

`src/` holds the GIMP sources and the pristine archive downloads — about 110 MB.
It is stored in Git LFS, and `.lfsconfig` excludes it from fetch, so a clone
gets pointer files rather than the bytes. That exclusion matters because
`omarchy theme install` is a plain `git clone`: without it every user would pull
110 MB to get a 26 MB `backgrounds/` directory. Nothing installs from `src/`
either — `deploy-theme.sh` only ever reads `backgrounds/*.png`.

To work on the wallpapers, fetch it:

```bash
git lfs pull --exclude="" --include="src/**"
```

The empty `--exclude` is not optional: `--include` overrides `lfs.fetchinclude`,
not `lfs.fetchexclude`, so without it the pull fetches nothing and reports no
error.

## Developing on the theme

```bash
tools/deploy-theme.sh                # mirror the theme into the live theme dir
omarchy theme set frutiger-aero      # re-apply
```

The deployed copy stays "user-written" (no `.git`), so Omarchy stages
`hyprland.lua` from it verbatim — `deploy-theme.sh` maps
`hypr/frutiger-aero.lua` there. That is what makes the local loop different
from the published one: your own theme dir may carry the Hyprland chrome the
cloned-theme contract would drop.

Plugin and theme-file changes are guarded by pre-commit hooks: `qmllint` and
`qmlformat` run on staged QML (type info for `qs.Commons` / `qs.Ui` resolves
via `tools/qml-imports/`). Enable them with `pre-commit install`.

## Caveats

`plugins/genkerensky.bar/` is a fork of Omarchy's bar, frozen at 4.0.1, so
upstream bar fixes will not reach you. It changes five hunks in one file;
everything else is verbatim upstream. See [NOTICE.md](NOTICE.md), which records
each change and why — including the upstream bug that makes *any* custom bar
fail to load, and takes the documented fallback down with it.

Built against Omarchy 4.0.1, Hyprland 0.56.2, Qt 6.11.

## License

MIT. Portions derived from Omarchy, also MIT — see [NOTICE.md](NOTICE.md).
The two `blissoom` wallpapers, and their sources in `src/`, are third-party and
excluded — see [Wallpaper attribution](#wallpaper-attribution).
