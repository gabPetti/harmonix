return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    -- `keys` alone would lazy-load the plugin, leaving `:ToggleTerm` unknown
    -- until a mapping was pressed.
    cmd = { "ToggleTerm", "TermExec", "ToggleTermToggleAll" },
    opts = {
      size = function(term)
        if term.direction == "horizontal" then
          return 15
        elseif term.direction == "vertical" then
          return vim.o.columns * 0.3
        end
      end,
      -- Works in normal, insert and terminal mode, unlike the <C-\> entry in
      -- `keys` below, which only exists to lazy-load the plugin.
      open_mapping = [[<c-\>]],
      hide_numbers = true,
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      insert_mappings = true,
      terminal_mappings = true,
      persist_size = true,
      persist_mode = true,
      direction = "float",
      close_on_exit = true,
      shell = vim.o.shell,
      float_opts = {
        border = "curved",
        winblend = 0,
        highlights = { border = "Normal", background = "Normal" },
      },
    },
    keys = {
      { "<C-\\>", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal", mode = { "n", "t" } },
      { "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Terminal (float)" },
      { "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Terminal (horizontal split)" },
      { "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", desc = "Terminal (vertical split)" },

      { "<leader>t1", "<cmd>1ToggleTerm<cr>", desc = "Terminal #1" },
      { "<leader>t2", "<cmd>2ToggleTerm<cr>", desc = "Terminal #2" },
      { "<leader>t3", "<cmd>3ToggleTerm<cr>", desc = "Terminal #3" },

      {
        "<leader>tc",
        function()
          -- A fixed id makes this one terminal: `Terminal:new` returns the
          -- already-registered terminal for that id. Without it, every press
          -- got a fresh id and started a second Claude session alongside the
          -- first instead of toggling the running one back into view.
          local claude = require("toggleterm.terminal").Terminal:new({
            count = 99,
            cmd = "claude",
            direction = "vertical",
            hidden = true,
          })
          claude:toggle()
        end,
        desc = "Toggle Claude Code",
      },
    },
    config = function(_, opts)
      require("toggleterm").setup(opts)

      -- Inside a terminal, Ctrl+h/j/k/l should move between splits rather than
      -- reaching the shell, and `jk` is a faster escape hatch to normal mode.
      vim.api.nvim_create_autocmd("TermOpen", {
        group = vim.api.nvim_create_augroup("harmonix_toggleterm_keymaps", { clear = true }),
        pattern = "term://*toggleterm#*",
        callback = function(event)
          local function map(lhs, rhs)
            vim.keymap.set("t", lhs, rhs, { buffer = event.buf })
          end
          map("jk", [[<C-\><C-n>]])
          map("<C-h>", [[<Cmd>wincmd h<CR>]])
          map("<C-j>", [[<Cmd>wincmd j<CR>]])
          map("<C-k>", [[<Cmd>wincmd k<CR>]])
          map("<C-l>", [[<Cmd>wincmd l<CR>]])
          map("<C-w>", [[<C-\><C-n><C-w>]])
        end,
      })
    end,
  },
}
