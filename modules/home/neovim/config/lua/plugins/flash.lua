return {
  -- Label-based motion: type a couple of characters and jump straight to any
  -- match on screen, instead of counting w/b or guessing a relative line.
  --
  -- Loaded eagerly rather than on its own keys: most of what it does is take
  -- over motions that already exist -- f, t, ; and , get labels on every
  -- further match, and / and ? get labels on every hit -- and none of that
  -- happens until the plugin is in memory.
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash jump",
      },
      {
        "S",
        mode = { "n", "x", "o" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash treesitter node",
      },
      -- Operator-pending only, so `r` keeps meaning replace-character in
      -- normal mode: `yr` then a label yanks a textobject somewhere else on
      -- screen without moving the cursor there.
      {
        "r",
        mode = "o",
        function()
          require("flash").remote()
        end,
        desc = "Remote flash",
      },
      {
        "R",
        mode = { "o", "x" },
        function()
          require("flash").treesitter_search()
        end,
        desc = "Treesitter search",
      },
      -- Command mode only -- the <C-s> in lua/config/keymaps.lua is bound in
      -- normal, insert, visual and select -- so this turns flash's labels off
      -- for one search when they get in the way.
      {
        "<C-s>",
        mode = "c",
        function()
          require("flash").toggle()
        end,
        desc = "Toggle flash search",
      },
    },
  },
}
