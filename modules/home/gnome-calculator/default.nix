{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # GTK4/libadwaita, so it follows the matugen palette via gtk4 extraCss.
    gnome-calculator
  ];
}
