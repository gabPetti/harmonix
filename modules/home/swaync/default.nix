{ pkgs, ... }:

{
  home.packages = with pkgs; [
    swaynotificationcenter
  ];

  harmonix.configLinks."swaync" = "swaync";
}
