{ pkgs, ... }:

{
  home.packages = with pkgs; [
    neovim

    tree-sitter

    # Languages
    jdk
    jdt-language-server # Java Language Server

    # LSPs & Formatters
    stylua # Lua
    black # Python
    shfmt # Shell / Bash
    nixpkgs-fmt # Nix
    google-java-format # Java
    lua-language-server

    # Search & Build utilities
    ripgrep
    fd
    gcc
    gnumake
  ];

  harmonix.configLinks."nvim" = "neovim";
}
