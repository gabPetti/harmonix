{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
    rofi
  ];

  # xdg.configFile."rofi".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/harmonix/modules/home/rofi/config";
}
