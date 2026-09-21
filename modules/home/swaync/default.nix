{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
    swaynotificationcenter
  ];

  xdg.configFile."swaync".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/harmonix/modules/home/swaync/config";
}
