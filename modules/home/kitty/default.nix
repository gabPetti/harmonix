{ pkgs, ... }:

{
  home.packages = with pkgs; [
    kitty
  ];

  harmonix.configLinks."kitty" = "kitty";
}
