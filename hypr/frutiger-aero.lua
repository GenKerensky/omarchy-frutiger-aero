-- Frutiger Aero — Deep Reef window chrome and shell layer rules.
--
-- Two ways this file ships: install.sh copies it to
-- ~/.config/hypr/frutiger-aero.lua and adds require("hypr.frutiger-aero") to
-- hyprland.lua, while tools/deploy-theme.sh copies it into the live theme dir
-- as hyprland.lua for local development. Either way it loads after Omarchy's
-- theme module and after looknfeel.lua, so it owns the Aero window chrome.
-- uninstall.sh reverses the install.sh path.
--
-- Hyprland cannot draw gloss: no bevels, no specular highlights. The Aero
-- read is assembled from what it *can* do — a 45° gradient border, generous
-- rounding with a raised rounding_power for the squircle shoulder, a coloured
-- shadow that behaves like a glow, and blur tuned for vibrancy rather than
-- for softness.

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

-- Frosted-glass blur behind the translucent Omarchy shell surfaces.
--
--   blur         frosts the layer surface itself (bar strip, menu, notifs, ...)
--   blur_popups  frosts that layer's xdg-popups -- the tray menu and the media
--                popout are popups of omarchy-bar, so they need this
--                (decoration:blur:popups only covers app window popups).
--   ignore_alpha skips any pixel whose alpha is at or below the value given.
--
-- Two groups, because two shapes of surface want different thresholds.
--
-- PANELS paint chrome and nothing else: the bar strip, a notification, an OSD
-- pill, a bar panel's card. The layer may be bar-sized or full-screen, but
-- every pixel outside the chrome is fully transparent, so a threshold just
-- above zero frosts the chrome and skips the empty space. Without it the
-- transparent pixels around the rounded corners pick up a square blur halo.
--
-- OVERLAYS are full-screen surfaces: a dim scrim covering the entire display
-- with the actual card floating on top of it. At the panel threshold Hyprland
-- blurs the scrim as well, which blurs the whole desktop behind the menu. The
-- theme puts scrims at 0.45-0.55 and the cards composite to roughly 0.8, so a
-- threshold between the two frosts the card and leaves the desktop sharp.
local PANEL_IGNORE_ALPHA = 0.01
local OVERLAY_IGNORE_ALPHA = 0.65

local blur_layers = {
  [PANEL_IGNORE_ALPHA] = {
    "omarchy-bar",
    -- Every bar panel -- clock, audio, network, power, weather, bluetooth,
    -- tailscale, and the rest -- opens as one shared full-screen layer under
    -- this namespace rather than as a popup of the bar. Without it the panel
    -- cards are plain translucency and you read the window behind them.
    "omarchy-keyboard-panel",
    "omarchy-notifications",
    "omarchy-osd",
    -- Polkit stays with the panels on purpose. Obscuring the desktop behind
    -- a password prompt is a focus cue, not a bug.
    "omarchy-polkit",
  },
  [OVERLAY_IGNORE_ALPHA] = {
    "omarchy-menu",
    "omarchy-clipboard",
    "omarchy-emojis",
    "omarchy-reminders",
    "omarchy-network-qr",
    "omarchy-image-selector",
  },
}

for ignore_alpha, namespaces in pairs(blur_layers) do
  for _, ns in ipairs(namespaces) do
    hl.layer_rule({
      match = { namespace = ns },
      blur = true,
      blur_popups = true,
      ignore_alpha = ignore_alpha,
    })
  end
end
