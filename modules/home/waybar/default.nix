{ pkgs, ... }:

{
  home.packages = with pkgs; [
    waybar
  ];

  harmonix.configLinks."waybar" = "waybar";
}
