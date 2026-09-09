{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
    waybar
  ];

  xdg.configFile."waybar".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/harmonix/modules/home/waybar/config";
}
