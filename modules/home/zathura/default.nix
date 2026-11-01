{ pkgs, ... }:

{
  home.packages = with pkgs; [
    zathura
  ];

  harmonix.configLinks."zathura" = "zathura";
}
