-- Frosted-glass blur behind the translucent Omarchy shell surfaces.
--
--   blur         frosts the layer surface itself (bar strip, menu, notifs, ...)
--   blur_popups  frosts that layer's xdg-popups -- the bar's calendar/audio/
--                network/... panels are popups of omarchy-bar, so they need
--                this (decoration:blur:popups only covers app window popups).
--   ignore_alpha skips any pixel whose alpha is at or below the value given.
--
-- Two groups, because two shapes of surface want different thresholds.
--
-- PANELS are small surfaces that fill their own layer. They only need the
-- fully-transparent pixels of their rounded corners skipped, or the corners
-- pick up a square blur halo. Hence a threshold just above zero.
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
