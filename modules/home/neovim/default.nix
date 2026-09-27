{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    neovim

    tree-sitter

    # Languages
    jdk
    # nodejs
    jdt-language-server # Java Language Server

    # LSPs & Formatters
    stylua # Lua
    black # Python
    shfmt # Shell / Bash
    nixpkgs-fmt # Nix
    # prettierd # JS / TS / Web
    google-java-format # Java
    lua-language-server

    # Search & Build utilities
    ripgrep
    fd
    gcc
    gnumake
  ];

  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/harmonix/modules/home/neovim/config";
}
