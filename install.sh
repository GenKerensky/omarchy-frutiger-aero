#!/usr/bin/env bash
# Frutiger Aero post-install: the extras Omarchy will not run from a cloned
# theme.
#
# `omarchy theme install` stages only colour: every .lua in a theme from a git
# repo is dropped, so the window chrome and shell blur rules cannot ship in
# the theme itself, and the shell plugins are separate artifacts entirely.
# This script installs the rest:
#
#   - the three shell plugins (bar, workspaces, aero-menu)
#   - the theme-set hook that swaps the Aero bar in and out with the theme
#   - the Hyprland window chrome + shell blur layer rules
#
# Safe to re-run: everything updates in place. uninstall.sh reverses it.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGINS_DIR="$HOME/.config/omarchy/plugins"
HYPR_DIR="$HOME/.config/hypr"
HYPR_ENTRY="$HYPR_DIR/hyprland.lua"
HYPR_CHROME="$HYPR_DIR/frutiger-aero.lua"
REQUIRE_LINE='require("hypr.frutiger-aero")'
MARKER_BEGIN="# >>> frutiger-aero theme >>>"
MARKER_END="# <<< frutiger-aero theme <<<"

say() { printf '%s\n' "$*"; }

command -v omarchy >/dev/null || {
  say "omarchy CLI not found; this script is for Omarchy systems." >&2
  exit 1
}

# --- plugins -----------------------------------------------------------------

mkdir -p "$PLUGINS_DIR"
for src in "$REPO_ROOT"/plugins/genkerensky.*; do
  [[ -d $src ]] || continue
  id=$(jq -r .id "$src/manifest.json")
  dst="$PLUGINS_DIR/$id"
  if [[ -d $dst/.git ]]; then
    say "plugin $id is a git install; leaving it alone (update it with: omarchy plugin update $id)"
    continue
  fi
  rm -rf "$dst"
  cp -a "$src" "$dst"
  say "installed plugin $id"
done
omarchy-shell shell rescanPlugins >/dev/null 2>&1 || true

# --- theme-set hook ------------------------------------------------------------

omarchy hook install theme-set "$REPO_ROOT/hooks/theme-set.d/aero-bar.hook"

# --- Hyprland chrome -----------------------------------------------------------

mkdir -p "$HYPR_DIR"
cp "$REPO_ROOT/hypr/frutiger-aero.lua" "$HYPR_CHROME"
say "installed Hyprland chrome at $HYPR_CHROME"

if [[ -f $HYPR_ENTRY ]]; then
  if grep -qF "$REQUIRE_LINE" "$HYPR_ENTRY"; then
    say "require line already present in $HYPR_ENTRY"
  else
    stamp=$(date +%s)
    cp "$HYPR_ENTRY" "$HYPR_ENTRY.bak.$stamp"
    {
      echo ""
      echo "$MARKER_BEGIN"
      echo "$REQUIRE_LINE"
      echo "$MARKER_END"
    } >>"$HYPR_ENTRY"
    say "added require line to $HYPR_ENTRY (backup: $HYPR_ENTRY.bak.$stamp)"
  fi
else
  say "WARNING: $HYPR_ENTRY not found; created $HYPR_CHROME but nothing loads it yet." >&2
  say "         Add require(\"hypr.frutiger-aero\") to your Hyprland entry config." >&2
fi

# --- done ----------------------------------------------------------------------

cat <<EOF

Done. Activate it:

  omarchy theme set frutiger-aero    # the hook swaps the Aero bar in

Optional: replace the stock menu button with the Aero gel. That edit touches
bar layout and plugin lists in shell.json, so it is documented rather than
automated — see README.md, "The menu button".
EOF
