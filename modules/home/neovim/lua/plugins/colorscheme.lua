return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "night",
      transparent = true, -- Enables base transparency
      styles = {
        sidebars = "transparent", -- Makes Snacks Explorer transparent
        floats = "transparent", -- Makes Snacks Picker / Popups transparent
      },
    },
  },
}
