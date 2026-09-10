{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
    matugen
  ];

  xdg.configFile."matugen".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/harmonix/modules/home/matugen/config";
}
