{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
    kitty
  ];

  xdg.configFile."kitty".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/harmonix/modules/home/kitty/config";
}
