{ pkgs, ... }:

{
  xdg = {
    # 1. Enable and configure Desktop Portals
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk # Fallback for file pickers and GTK dialogs
      ];
      config = {
        common = {
          default = [ "hyprland" "gtk" ];
        };
      };
    };
  };
}
