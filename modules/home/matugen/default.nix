{ pkgs, ... }:

{
  home.packages = with pkgs; [
    matugen
  ];

  harmonix.configLinks."matugen" = "matugen";
}
