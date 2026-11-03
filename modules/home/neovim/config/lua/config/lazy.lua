-- lazy.nvim bootstrap. The plugin itself is cloned into stdpath("data") rather
-- than installed from nixpkgs, so `:Lazy update` stays in charge of plugin
-- versions and `lazy-lock.json` (in this repo) is the record of them.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", repo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({ { "Failed to clone lazy.nvim:\n", "ErrorMsg" }, { out, "WarningMsg" } }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = { { import = "plugins" } },
  defaults = { lazy = false, version = false }, -- version=false: track HEAD, not latest tag
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = { enabled = true, notify = false }, -- check for updates, don't nag
  change_detection = { notify = false },
  -- LSPs, formatters and tree-sitter CLI come from
  -- modules/home/neovim/default.nix, so nothing here should download binaries.
  rocks = { enabled = false },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
        "netrwPlugin",
      },
    },
  },
})

vim.keymap.set("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })
