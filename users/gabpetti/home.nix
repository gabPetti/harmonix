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
    ../../modules/home/zathura
    ../../modules/home/calcure
    ../../modules/home/cursor
    ../../modules/home/stremio
    ../../modules/home/intellij
    ../../modules/home/swayosd
  ];

  services.playerctld.enable = true;
  modules.swayosd.enable = true;

  home.stateVersion = "26.11";
}

