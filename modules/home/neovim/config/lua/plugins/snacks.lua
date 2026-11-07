-- snacks.nvim stands in for a pile of single-purpose plugins: the picker
-- (files, grep, references), the file explorer, dashboard, notifications,
-- buffer deletion that keeps the window layout, and the big-file guard.
return {
  {
    "folke/snacks.nvim",
    priority = 900,
    -- Explicit, and load-bearing: `keys` below would otherwise make this spec
    -- lazy (a `keys`/`cmd`/`event`/`ft` handler wins over
    -- `defaults.lazy = false`). Loading snacks only on the first keypress means
    -- `Snacks.setup()` runs after VimEnter, where it sets the dashboard up
    -- immediately instead of on UIEnter — so the dashboard never showed at
    -- startup, and tried to open mid-session from whatever context pressed the
    -- key (E565: not allowed to change text or change window).
    lazy = false,
    opts = {
      bigfile = { enabled = true }, -- disable treesitter/LSP on huge files
      quickfile = { enabled = true }, -- render the file before loading plugins
      notifier = { enabled = true },
      indent = { enabled = true },
      input = { enabled = true },
      -- Inline image previews in markdown, drawn with kitty's graphics
      -- protocol. Needs imagemagick on PATH (this module's default.nix).
      image = { enabled = true },
      scope = { enabled = true },
      words = { enabled = true },
      picker = {
        sources = {
          explorer = {
            hidden = true, -- dotfiles (.gitignore, .github, …)
            ignored = true, -- git-ignored entries (.env, node_modules, …)
          },
          -- Dotfiles are the point of this repo, so find/grep should see them
          -- too; .git is still excluded by the picker's own defaults.
          files = { hidden = true },
          grep = { hidden = true },
        },
      },
      dashboard = {
        preset = {
          header = [[  .,-:::::     ...    :::::::-.    :::.         .-:::::'   ...     .-:::::'   ...     
,;;;'````'  .;;;;;;;.  ;;,   `';,  ;;`;;        ;;;'''' .;;;;;;;.  ;;;'''' .;;;;;;;.  
[[[        ,[[     \[[,`[[     [[ ,[[ '[[,      [[[,,==,[[     \[[,[[[,,==,[[     \[[,
$$$        $$$,     $$$ $$,    $$c$$$cc$$$c     `$$$"``$$$,     $$$`$$$"``$$$,     $$$
`88bo,__,o,"888,_ _,88P 888_,o8P' 888   888,     888   "888,_ _,88P 888   "888,_ _,88P
 "YUMMMMMP" "YMMMMMP"  MMMMP"`   YMM   ""`      "MM,    "YMMMMMP"  "MM,    "YMMMMMP"]],
        },
        sections = {
          { section = "header" },
          { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
          { section = "startup" },
        },
      },
    },
    -- stylua: ignore
    keys = {
      -- Find
      { "<leader><space>", function() Snacks.picker.smart() end, desc = "Smart find files" },
      { "<leader>ff", function() Snacks.picker.files() end, desc = "Find files" },
      { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
      { "<leader>e", function() Snacks.explorer() end, desc = "File explorer" },
      -- Search
      { "<leader>sg", function() Snacks.picker.grep() end, desc = "Grep" },
      { "<leader>sw", function() Snacks.picker.grep_word() end, mode = { "n", "x" }, desc = "Grep word/selection" },
      { "<leader>sb", function() Snacks.picker.lines() end, desc = "Grep buffer lines" },
      { "<leader>sr", function() Snacks.picker.resume() end, desc = "Resume last picker" },
      { "<leader>sn", function() Snacks.picker.notifications() end, desc = "Notification history" },
      -- Code
      -- Overrides nvim 0.11's own grr, which sends references to the quickfix
      -- list; the picker is the better surface for them.
      { "grr", function() Snacks.picker.lsp_references() end, desc = "LSP references" },
      -- Git
      { "<leader>gb", function() Snacks.picker.git_branches() end, desc = "Git branches" },
      { "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git log" },
      { "<leader>gf", function() Snacks.picker.git_log_file() end, desc = "Git log (file)" },
      -- Buffers / UI
      { "<leader>bD", function() Snacks.bufdelete() end, desc = "Delete buffer (keep layout)" },
      { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss notifications" },
      { "<leader>z", function() Snacks.zen() end, desc = "Toggle zen mode" },
      -- Terminal
      {
        "<leader>tt",
        function()
          -- No cmd, so this is $SHELL. `count` is left to vim.v.count1, which
          -- makes 2<leader>tt a second independent terminal, 3<leader>tt a
          -- third, and so on.
          Snacks.terminal.toggle(nil, {
            win = { position = "bottom", height = 0.3 },
          })
        end,
        desc = "Terminal (bottom)",
      },
      {
        "<leader>tc",
        function()
          Snacks.terminal.toggle("claude", {
            -- Both of these pin the terminal's identity so there is only ever
            -- one Claude session: a fixed `count` keeps vim.v.count1 out of it
            -- (a stray count would otherwise start a second one), and the
            -- global cwd keeps a window-local `:lcd` from doing the same.
            count = 99,
            cwd = vim.fn.getcwd(-1, -1),
            win = { position = "right", width = 0.3 },
          })
        end,
        desc = "Claude Code (right)",
      },
    },
  },
}
