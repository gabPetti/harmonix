{ pkgs, ... }:

{
  home.packages = with pkgs; [
    fastfetch
  ];

  harmonix.configLinks."fastfetch" = "fastfetch";
}
