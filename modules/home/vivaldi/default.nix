{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
    vivaldi
  ];

  xdg.configFile."vivaldi/Default/Preferences".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/harmonix/modules/home/vivaldi/config/Preferences";
}
