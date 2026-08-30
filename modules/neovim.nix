{ pkgs, ... }:

{
  # 1. Enable and configure Neovim wrapper
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # 2. Only extra tooling (LSPs, treesitter compilers, formatters)
  environment.systemPackages = with pkgs; [
    ripgrep
    fd
    gcc
    lua-language-server
  ];
}
