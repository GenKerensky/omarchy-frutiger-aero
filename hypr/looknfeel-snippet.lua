-- Machine-level baseline for ~/.config/hypr/looknfeel.lua.
--
-- This file loads AFTER the current theme's hyprland.lua, so anything set here
-- wins over the theme. Keep it minimal and let the theme own the look: the
-- Frutiger Aero theme sets rounding, rounding_power, shadow, and the full blur
-- tuning (size / passes / vibrancy / noise) in its own hyprland.lua.
--
-- Blur stays enabled here so themes that do not configure it still get frosted
-- shell surfaces rather than flat translucency.
hl.config({
  decoration = {
    blur = {
      enabled = true,
    },
  },
})
