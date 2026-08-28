#!/usr/bin/env bash
# Render the background sources to 3840x2160 PNGs with headless Chromium.
#
# The wallpapers are generated rather than sourced so they match colors.toml
# exactly -- Hyprland's blur picks its colour up off whatever sits behind the
# glass, so a background that drifts from the palette makes every translucent
# surface drift with it.
set -euo pipefail

src="${1:-backgrounds-src}"
dst="${2:-../themes/frutiger-aero/backgrounds}"

python3 "$(dirname "$0")/generate-backgrounds.py" "$src"
mkdir -p "$dst"

for f in "$src"/*.html; do
  n=$(basename "$f" .html)
  chromium --headless=new --disable-gpu --hide-scrollbars \
    --force-device-scale-factor=1 --window-size=3840,2160 \
    --virtual-time-budget=6000 \
    --screenshot="$dst/$n.png" "file://$(realpath "$f")"
  echo "rendered $n.png"
done
