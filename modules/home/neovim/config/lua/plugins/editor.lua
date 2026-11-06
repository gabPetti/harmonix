return {
  -- Pending-keymap popup. Also the thing that makes <leader> groups legible,
  -- hence the group labels for the prefixes used across this config.
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "helix",
      spec = {
        { "<leader>b", group = "buffer" },
        { "<leader>c", group = "code" },
        { "<leader>f", group = "file/find" },
        { "<leader>g", group = "git" },
        { "<leader>q", group = "quit" },
        { "<leader>s", group = "search" },
        { "<leader>t", group = "terminal" },
        { "<leader>u", group = "ui/toggle" },
        { "<leader>w", group = "window" },
        { "<leader>x", group = "diagnostics/quickfix" },
        { "gs", group = "surround" },
      },
    },
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer keymaps",
      },
    },
  },

  -- mini.nvim pieces, each small enough not to deserve its own file.
  {
    "echasnovski/mini.nvim",
    event = "VeryLazy",
    config = function()
      require("mini.pairs").setup() -- auto-close brackets and quotes

      -- gs rather than mini's own s prefix: flash.nvim owns s as a motion
      -- (lua/plugins/flash.lua), and with both bound every `s` would stall
      -- for timeoutlen waiting to see whether a surround key followed. `gs`
      -- is Vim's "sleep for count seconds", which is no loss.
      require("mini.surround").setup({
        mappings = {
          add = "gsa", -- gsa<motion><char> to surround
          delete = "gsd", -- gsd<char> to remove
          replace = "gsr", -- gsr<from><to> to change
          find = "gsf", -- jump to the next surrounding char
          find_left = "gsF",
          highlight = "gsh",
        },
      })
      require("mini.ai").setup() -- richer a/i textobjects, incl. tree-sitter ones
      require("mini.icons").setup() -- icon provider for snacks, lualine, …
      require("mini.icons").mock_nvim_web_devicons()
    end,
  },

  -- Diagnostics, references and quickfix in one navigable list.
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = {},
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (workspace)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Diagnostics (buffer)" },
      { "<leader>xs", "<cmd>Trouble symbols toggle<cr>", desc = "Symbols" },
      { "<leader>xl", "<cmd>Trouble loclist toggle<cr>", desc = "Location list" },
      { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix list" },
    },
  },

  -- TODO/FIXME/HACK comments, highlighted and searchable.
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
    keys = {
      { "<leader>st", "<cmd>TodoTrouble<cr>", desc = "Todo list" },
      {
        "]t",
        function()
          require("todo-comments").jump_next()
        end,
        desc = "Next todo comment",
      },
      {
        "[t",
        function()
          require("todo-comments").jump_prev()
        end,
        desc = "Previous todo comment",
      },
    },
  },
}
