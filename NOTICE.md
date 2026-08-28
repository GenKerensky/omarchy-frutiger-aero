# Provenance

Built against **Omarchy 4.0.1** / **Hyprland 0.56.2** / **Qt 6.11**.

Omarchy is MIT licensed, so the forked files below are redistributed under the
same terms. This file records exactly what came from upstream and what changed,
so a future `omarchy update` can be reconciled without guesswork.

## `plugins/genkerensky.bar/`

Cloned from Omarchy's `omarchy.bar` via `omarchy plugin clone`. Everything is
upstream verbatim except the files noted here:

| file | status |
|---|---|
| `BarModel.js`, `README.md` | identical to upstream |
| `widgets/` (18 files), `indicators/` (6 files) | all 24 identical to upstream |
| `manifest.json` | id and name rewritten by `omarchy plugin clone` |
| `Bar.qml` | 5 changed hunks, described below |

### `Bar.qml` changes

1. **Lines 15–30 — three root properties lose `required`.**
   Not cosmetic; this is what makes a custom bar load at all. `shell.qml` loads
   a non-default bar through a `Loader` `source:` URL, and a `Loader` cannot
   instantiate a component whose root declares required properties: they must
   be bound at construction, while the host injects them from `configureBar()`
   in `onLoaded`, one step too late. Left as-is, the bar fails with
   `Required property omarchyPath was not initialized` and draws nothing.

   Worse, the documented fallback does not save you. The `Loader.Error` handler
   calls `errorString()`, which is not a method on QtQuick's `Loader`, so it
   throws `ReferenceError: errorString is not defined` *before* reaching
   `shell.failedBarId = shell.activeBarId`. The result is no bar at all rather
   than a graceful drop back to `omarchy.bar`.

2. **After line ~1025 — the gloss layer.** A moulded gradient with a hard break
   at the midline, a specular cap, a bright hairline on the screen edge, and an
   accent-tinted lit edge facing the desktop. Declared before the `Loader` so
   widgets draw over it, and containing no input items so it never steals a
   click. Every value is a tint, a shade, or `Color.accent`, so the bar glosses
   correctly under any theme rather than only this one.

3. **Line ~1114 — `LeftModules` left inset zeroed** (was `Style.space(8)`), so
   the Aero menu button sits flush in the top-left corner. That button supplies
   its own inset. Restore `Style.space(8)` if it ever leaves the left section.

## `plugins/genkerensky.workspaces/`

Cloned from `omarchy.workspaces`. Rewritten to draw monitor-shaped gel pills
with the label centred on the glyph's painted box.

## `plugins/genkerensky.aero-menu/`

Original. Deliberately *not* a clone of `omarchy.menu`: that plugin ships both
the bar button and a 1420-line menu overlay, and cloning it to restyle one
button would fork the overlay too. This widget makes the same IPC call and
leaves `omarchy.menu` to go on providing the menu.

## `assets/omarchy-mark.svg`

Glyph U+E900 extracted from `/usr/share/fonts/omarchy/omarchy.ttf` with
fontTools. Omarchy's mark, redrawn as a path; `fill="currentColor"`.
