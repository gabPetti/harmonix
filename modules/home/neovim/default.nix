{ pkgs, ... }:

{
  home.packages = with pkgs; [
    neovim

    tree-sitter

    # Languages
    jdk
    jdt-language-server # Java Language Server

    # LSPs & Formatters
    # Everything referenced by lua/plugins/conform.lua and lua/plugins/lsp.lua
    # comes from here rather than Mason, so the two lists must stay in sync.
    stylua # Lua
    black # Python
    shfmt # Shell / Bash
    nixpkgs-fmt # Nix
    google-java-format # Java
    prettierd # Web (JS/TS, JSON, YAML, CSS, HTML, Markdown)
    lua-language-server
    nixd # Nix LSP, with NixOS/Home Manager option completion

    # Backs clipboard = unnamedplus in lua/config/options.lua; without it every
    # yank silently stays inside neovim.
    wl-clipboard

    # Search & Build utilities
    ripgrep
    fd
    gcc
    gnumake
  ];

  harmonix.configLinks."nvim" = "neovim";
}
