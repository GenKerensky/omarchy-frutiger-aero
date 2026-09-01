return {
  {
    "omacom-io/aether.nvim",
    branch = "v3",
    name = "aether",
    priority = 1000,
    opts = {
      colors = {
        bg         = "#00071A",
        dark_bg    = "#000514",
        darker_bg  = "#00040d",
        lighter_bg = "#1a2031",

        fg         = "#DBE5FC",
        dark_fg    = "#a4acbd",
        light_fg   = "#e0e9fc",
        bright_fg  = "#e4ecfd",
        muted      = "#5b5f64",

        red        = "#ff5b52",
        yellow     = "#ffc73d",
        orange     = "#ff9838",
        green      = "#78c75f",
        cyan       = "#2fd1dc",
        blue       = "#4c6eff",
        purple     = "#ff5fa8",
        brown      = "#c58a5b",

        bright_red    = "#ff7a6b",
        bright_yellow = "#ffc73d",
        bright_green  = "#8eec5b",
        bright_cyan   = "#5ee3ec",
        bright_blue   = "#6e8bff",
        bright_purple = "#ff82c0",

        accent               = "#4c6eff",
        cursor               = "#DBE5FC",
        foreground           = "#DBE5FC",
        background           = "#00071A",
        selection             = "#1a2031",
        selection_foreground = "#DBE5FC",
        selection_background = "#1a2031",
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "aether",
    },
  },
}
