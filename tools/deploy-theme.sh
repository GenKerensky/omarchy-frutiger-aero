#!/usr/bin/env bash
# Copy the theme from the repo root into the live theme directory.
#
# The deployed copy stays "user-written" (no .git), so Omarchy stages whatever
# is there verbatim -- including hyprland.lua, which this maps from
# hypr/frutiger-aero.lua. That is the local development loop: edit here,
# deploy, then `omarchy theme set frutiger-aero` to re-apply.
#
# backgrounds/ is mirrored rather than copied. Omarchy picks the default
# background by sorting that directory and taking the first file, so a wallpaper
# left behind from an earlier deploy does not just sit there unused -- it stays
# in the rotation and can win the sort. The theme's own root files are a fixed
# set and are simply overwritten; nothing accumulates there.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
THEME_DIR="${1:-$HOME/.config/omarchy/themes/frutiger-aero}"

mkdir -p "$THEME_DIR/backgrounds"
cp -f "$ROOT/colors.toml" "$ROOT/shell.toml" "$ROOT/icons.theme" "$THEME_DIR/"
cp -f "$ROOT/hypr/frutiger-aero.lua" "$THEME_DIR/hyprland.lua"

# Name what goes, so a mirror never deletes anything silently.
for dead in "$THEME_DIR"/backgrounds/*; do
  [[ -e $dead ]] || continue
  [[ -e "$ROOT/backgrounds/$(basename "$dead")" ]] && continue
  rm -rf "$dead"
  echo "removed stale background $(basename "$dead")"
done

cp -f "$ROOT"/backgrounds/*.png "$THEME_DIR/backgrounds/"

echo "deployed to $THEME_DIR"
echo "re-apply with: omarchy theme set frutiger-aero"
