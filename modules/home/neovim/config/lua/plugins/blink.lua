return {
  {
    "saghen/blink.cmp",
    version = "1.*", -- release tags ship the prebuilt fuzzy matcher
    event = "InsertEnter",
    dependencies = { "rafamadriz/friendly-snippets" },
    opts = {
      keymap = {
        preset = "default", -- <C-space> opens, <C-n>/<C-p> cycle, <C-e> closes
        ["<Tab>"] = { "select_next", "fallback" },
        ["<S-Tab>"] = { "select_prev", "fallback" },
        ["<CR>"] = { "accept", "fallback" },
      },
      completion = {
        -- Never preselect or auto-insert: the menu is a suggestion, and <CR>
        -- stays a newline until something is explicitly selected.
        list = { selection = { preselect = false, auto_insert = false } },
        documentation = { auto_show = true, auto_show_delay_ms = 200 },
        ghost_text = { enabled = true },
      },
      -- Show the function signature while typing arguments.
      signature = { enabled = true },
      sources = {
        default = { "lsp", "path", "snippets", "buffer", "lazydev" },
        providers = {
          -- lazydev's results replace the lua_ls `require` completions, which
          -- are worse; the high score keeps them at the top.
          lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
        },
      },
      cmdline = { enabled = true },
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
    opts_extend = { "sources.default" },
  },
}
