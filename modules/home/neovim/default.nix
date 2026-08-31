{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;

    # Core build dependencies required by LazyVim plugins & Mason/Treesitter
    extraPackages = with pkgs; [
      # LazyVim core CLI dependencies
      git
      ripgrep
      fd
      fzf

      # Native compilers & build tools for Tree-sitter parsers
      gcc
      gnumake
      unzip
      wget
      curl
      tree-sitter

      # Common Language runtimes (Mason needs these to run LSPs/linters)
      nodejs
      python3
      lua5_1
      luajitPackages.luarocks
    ];
  };

  # Bootstrap LazyVim configuration files
  xdg.configFile."nvim/init.lua".text = ''
    -- Bootstrap lazy.nvim
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if not (vim.uv or vim.loop).fs_stat(lazypath) then
      local lazyrepo = "https://github.com/folke/lazy.nvim.git"
      local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
      if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
          { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
          { out, "WarningMsg" },
          { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
      end
    end
    vim.opt.rtp:prepend(lazypath)

    -- Setup LazyVim
    require("lazy").setup({
      spec = {
        { "LazyVim/LazyVim", import = "lazyvim.plugins" },
        -- Import your custom plugins from lua/plugins/*.lua
        -- { import = "plugins" },
      },
      defaults = {
        lazy = false,
        version = false,
      },
      checker = { enabled = true },
      performance = {
        rtp = {
          disabled_plugins = {
            "gzip",
            "tarPlugin",
            "tohtml",
            "tutor",
            "zipPlugin",
          },
        },
      },
    })
  '';

  # LazyVim options configuration
  xdg.configFile."nvim/lua/config/options.lua".text = ''
    -- Global options (LazyVim defaults are already set, add your overrides here)
    vim.g.mapleader = " "
    vim.g.maplocalleader = "\\"
  '';

  # LazyVim keymaps configuration
  xdg.configFile."nvim/lua/config/keymaps.lua".text = ''
    -- Custom keymaps go here
  '';

  # LazyVim autocmds configuration
  xdg.configFile."nvim/lua/config/autocmds.lua".text = ''
    -- Custom autocmds go here
  '';
}
