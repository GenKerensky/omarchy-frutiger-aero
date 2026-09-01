#!/usr/bin/env bash
# Reverses install.sh: removes the plugins, the theme-set hook, and the
# Hyprland chrome. The theme itself is removed through Omarchy:
# Super + Space > Remove > Theme (or delete ~/.config/omarchy/themes/frutiger-aero).
set -euo pipefail

PLUGINS_DIR="$HOME/.config/omarchy/plugins"
HOOK_PATH="$HOME/.config/omarchy/hooks/theme-set.d/aero-bar.hook"
HYPR_DIR="$HOME/.config/hypr"
HYPR_ENTRY="$HYPR_DIR/hyprland.lua"
HYPR_CHROME="$HYPR_DIR/frutiger-aero.lua"

say() { printf '%s\n' "$*"; }

# --- plugins -------------------------------------------------------------------

for id in genkerensky.bar genkerensky.workspaces genkerensky.aero-menu; do
  dst="$PLUGINS_DIR/$id"
  if [[ -d $dst/.git ]]; then
    say "plugin $id is a git install; not touching it (remove with: omarchy plugin remove $id)"
  elif [[ -d $dst ]]; then
    rm -rf "$dst"
    say "removed plugin $id"
  fi
done
omarchy-shell shell rescanPlugins >/dev/null 2>&1 || true

# --- hook ----------------------------------------------------------------------

if [[ -f $HOOK_PATH ]]; then
  rm "$HOOK_PATH"
  say "removed theme-set hook"
fi

# --- Hyprland chrome -----------------------------------------------------------

if [[ -f $HYPR_ENTRY ]] && grep -q '^# >>> frutiger-aero theme >>>$' "$HYPR_ENTRY"; then
  sed -i '/^# >>> frutiger-aero theme >>>$/,/^# <<< frutiger-aero theme <<<$/d' "$HYPR_ENTRY"
  say "removed require line from $HYPR_ENTRY"
fi
if [[ -f $HYPR_CHROME ]]; then
  rm "$HYPR_CHROME"
  say "removed $HYPR_CHROME"
fi

# --- done ----------------------------------------------------------------------

cat <<EOF

Done. Put the stock bar back if the Aero one is still active:

  omarchy bar use omarchy.bar

And restore the stock menu button by reversing the shell.json edit described
in README.md, "The menu button" (swap genkerensky.aero-menu back to
omarchy.menu and drop omarchy.menu from the top-level plugins array).
EOF
