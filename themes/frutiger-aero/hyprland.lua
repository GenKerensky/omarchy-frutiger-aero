-- Frutiger Aero — Deep Reef window chrome.
--
-- Hyprland cannot draw gloss: no bevels, no specular highlights. The Aero
-- read is assembled from what it *can* do — a 45° gradient border, generous
-- rounding with a raised rounding_power for the squircle shoulder, a coloured
-- shadow that behaves like a glow, and blur tuned for vibrancy rather than
-- for softness.
--
-- NOTE: ~/.config/hypr/looknfeel.lua loads AFTER this file, so anything it
-- sets in `decoration` wins over what's here. Its decoration block has been
-- reduced to `blur.enabled` for exactly that reason.

local active_border_color = { colors = { "rgba(17e0c8ee)", "rgba(0aa3e8ee)" }, angle = 45 }
local inactive_border_color = "rgba(0a3a4799)"

hl.config({
  general = {
    border_size = 2,
    col = {
      active_border = active_border_color,
      inactive_border = inactive_border_color,
    },
  },

  group = {
    col = {
      border_active = active_border_color,
      border_inactive = inactive_border_color,
    },
  },

  decoration = {
    -- Squircle shoulders. rounding_power > 2 keeps the straight run of the
    -- edge longer before it turns, which is what reads as moulded rather
    -- than as a rounded rectangle.
    rounding = 14,
    rounding_power = 4,

    -- A glow, not a drop shadow: centred, wide, and tinted with the accent.
    shadow = {
      enabled = true,
      range = 16,
      render_power = 3,
      offset = "0 0",
      color = "rgba(17e0c855)",
      color_inactive = "rgba(02141c77)",
    },

    blur = {
      enabled = true,
      -- Wide and soft. What's behind the glass should read as colour and
      -- movement, never as recognisable shapes.
      size = 10,
      passes = 3,
      -- The single most Aero setting available. Vista's composited blur
      -- re-saturated what it blurred; 0.17 (the default) does not.
      vibrancy = 0.40,
      vibrancy_darkness = 0.15,
      -- Ground-glass grain — also stops large frosted panels from banding.
      noise = 0.02,
      contrast = 1.05,
      brightness = 1.0,
      popups = true,
      popups_ignorealpha = 0.2,
    },
  },
})

-- Translucent chrome is the point; translucent body text is a mistake.
-- Terminals sit thin enough to pick up the wallpaper, opaque enough to read.
o.window({ tag = "terminal" }, { opacity = "0.90 0.86" })
