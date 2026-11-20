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
        map("n", "<leader>gB", function()
          gs.blame_line({ full = true })
        end, "Blame line")
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
      { "<leader>gc", "<cmd>DiffviewClose<cr>", desc = "Diffview close" },
    },
  },

  -- Diffview is pulled in as a Neogit dependency; give it its own spec so it
  -- gets the bare "q" to close, matching other full-screen UIs.
  --
  -- actions.close is only wired up by diffview's own defaults for the
  -- option_panel/help_panel contexts; in view/file_panel/file_history_panel
  -- it's a no-op (no handler bound to it), so those need the actual
  -- :DiffviewClose command to close the whole tab-page instead.
  {
    "sindrets/diffview.nvim",
    opts = {
      keymaps = {
        view = { ["q"] = "<cmd>DiffviewClose<cr>" },
        file_panel = { ["q"] = "<cmd>DiffviewClose<cr>" },
        file_history_panel = { ["q"] = "<cmd>DiffviewClose<cr>" },
      },
    },
  },
}
