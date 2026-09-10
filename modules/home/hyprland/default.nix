{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    hyprpaper
    hyprshot
    hyprsunset
    hyprlock
    hyprland-qt-support
  ];

  xdg.configFile."hypr".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/harmonix/modules/home/hyprland/config";

  # Only environment variables directly dictating Hyprland's execution belong here
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
  };
}
