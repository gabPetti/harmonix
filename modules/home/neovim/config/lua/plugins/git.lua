return {
  -- Signs in the gutter, hunk staging and blame for the current line.
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      on_attach = function(buffer)
        local gs = require("gitsigns")
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = buffer, desc = desc })
        end

        -- ]h / [h also work in diff mode, where gitsigns falls back to ]c.
        map("n", "]h", function()
          gs.nav_hunk("next")
        end, "Next hunk")
        map("n", "[h", function()
          gs.nav_hunk("prev")
        end, "Previous hunk")
        map({ "n", "x" }, "<leader>gs", gs.stage_hunk, "Stage hunk")
        map({ "n", "x" }, "<leader>gr", gs.reset_hunk, "Reset hunk")
        map("n", "<leader>gp", gs.preview_hunk_inline, "Preview hunk")
        map("n", "<leader>gB", function()
          gs.blame_line({ full = true })
        end, "Blame line")
        map("n", "<leader>gd", gs.diffthis, "Diff against index")
        map("o", "ih", gs.select_hunk, "Hunk")
        map("x", "ih", gs.select_hunk, "Hunk")
      end,
    },
  },

  -- Full-screen git UI for everything beyond hunk-level work: commits,
  -- rebases, branches.
  {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    dependencies = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim" },
    opts = {
      graph_style = "unicode",
      integrations = { diffview = true, snacks = true },
    },
    keys = {
      { "<leader>gg", "<cmd>Neogit<cr>", desc = "Neogit" },
      { "<leader>gc", "<cmd>Neogit commit<cr>", desc = "Neogit commit" },
    },
  },
}
