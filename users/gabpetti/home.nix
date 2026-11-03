{ ... }:

{
  imports = [
    # Shared option plumbing used by the app modules below.
    ../../modules/home/config-links.nix

    ../../modules/home/ssh
    ../../modules/home/neovim
    ../../modules/home/firefox
    ../../modules/home/gtk
    ../../modules/home/starship
    ../../modules/home/vscode
    ../../modules/home/obsidian
    ../../modules/home/hyprland
    ../../modules/home/quickshell
    ../../modules/home/kitty
    ../../modules/home/yazi
    ../../modules/home/matugen
    ../../modules/home/swaync
    ../../modules/home/fastfetch
    ../../modules/home/zathura
    ../../modules/home/calcure
    ../../modules/home/cursor
    ../../modules/home/stremio
  ];

  services.playerctld.enable = true;

  home.stateVersion = "26.11";
}
