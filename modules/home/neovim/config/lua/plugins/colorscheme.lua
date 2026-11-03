return {
  {
    "folke/tokyonight.nvim",
    priority = 1000, -- load before anything that sets highlights
    opts = {
      style = "night",
      -- Transparency has to be opted into per surface: the base flag leaves
      -- sidebars and floats opaque, which looks wrong over a translucent kitty.
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight")
    end,
  },
}
