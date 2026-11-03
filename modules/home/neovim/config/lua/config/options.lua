local opt = vim.opt

-- Leader has to be set before lazy.nvim and any plugin spec is loaded.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- UI
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes" -- no layout jitter when diagnostics/git signs appear
opt.cursorline = true
opt.termguicolors = true
opt.showmode = false -- the statusline already shows it
opt.laststatus = 3 -- one global statusline instead of one per split
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false
opt.splitbelow = true
opt.splitright = true
opt.splitkeep = "screen" -- keep the text put when a split opens above
opt.winborder = "rounded" -- all floats (LSP hover, diagnostics, …)
opt.pumheight = 10
opt.fillchars = { eob = " " } -- no ~ on the lines past the end of the buffer
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Editing
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.smartindent = true
opt.breakindent = true
opt.virtualedit = "block" -- let visual-block selections past end of line
opt.confirm = true -- ask instead of failing when quitting a dirty buffer

-- Search
opt.ignorecase = true
opt.smartcase = true -- …unless the pattern has an uppercase letter
opt.inccommand = "split" -- live preview of :s/… in a split
opt.grepprg = "rg --vimgrep"
opt.grepformat = "%f:%l:%c:%m"

-- Files: undo survives across sessions, swap files only ever produce
-- stale-recovery prompts, and everything worth keeping is in git anyway.
opt.undofile = true
opt.undolevels = 10000
opt.swapfile = false
opt.backup = false
opt.updatetime = 200 -- drives CursorHold and swap-less change detection

-- Every yank, delete and paste goes through the system clipboard, so y/p
-- interoperate with the rest of the desktop without a prefix. Needs
-- wl-clipboard on PATH (declared in this module's default.nix).
-- Note this means d/c/x overwrite the clipboard too; <leader>d in keymaps.lua
-- deletes into the black hole register when that is not wanted.
opt.clipboard = "unnamedplus"

-- Spell checking is on everywhere (not just prose): typos in identifiers and
-- comments are worth catching too. `camel` keeps CamelCase from being flagged
-- as one misspelled word; autocmds.lua turns it back off for UI buffers.
opt.spell = true
opt.spelllang = { "pt", "en" }
opt.spelloptions:append("camel")

-- `zg` writes added words here. stdpath("config") is an out-of-store symlink
-- into this repo, so the personal dictionary is version-controlled instead of
-- living in ~/.local/share and getting lost.
opt.spellfile = vim.fn.stdpath("config") .. "/spell/en.utf-8.add"

-- Diagnostics: virtual text off by default (it shifts code around); the
-- current line's diagnostics show in the statusline area via virtual_lines on
-- demand (<leader>ud below).
vim.diagnostic.config({
  severity_sort = true,
  underline = true,
  virtual_text = { prefix = "●", spacing = 2 },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.INFO] = " ",
      [vim.diagnostic.severity.HINT] = " ",
    },
  },
})
