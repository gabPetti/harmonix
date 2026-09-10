{ ... }:

{
  imports = [
    ../../modules/home/neovim
    ../../modules/home/firefox
    ../../modules/home/gtk
    ../../modules/home/starship
    ../../modules/home/vscode
    ../../modules/home/obsidian
    ../../modules/home/hyprland
    ../../modules/home/waybar
    ../../modules/home/kitty
    ../../modules/home/yazi
    ../../modules/home/rofi
    ../../modules/home/matugen
    ../../modules/home/swaync
    ../../modules/home/fastfetch
  ];

  services.playerctld.enable = true;

  home.stateVersion = "26.11";
}

