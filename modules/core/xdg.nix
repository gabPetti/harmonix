{ pkgs, ... }:

{
  environment.systemPackages = [
    (pkgs.makeDesktopItem {
      name = "nvim-term";
      desktopName = "Neovim (Terminal)";
      exec = "${pkgs.kitty}/bin/kitty -e ${pkgs.neovim}/bin/nvim %F";
      icon = "nvim";
      mimeTypes = [ "text/plain" "text/markdown" "application/json" "text/x-shellscript" ];
    })
  ];

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

    mime.defaultApplications = {
      "text/plain" = "nvim-term.desktop";
      "text/markdown" = "nvim-term.desktop";
      "application/json" = "nvim-term.desktop";
      "text/x-shellscript" = "nvim-term.desktop";
    };
  };
}
