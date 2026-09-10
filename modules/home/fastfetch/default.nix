{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
    fastfetch
  ];

  xdg.configFile."fastfetch".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/harmonix/modules/home/fastfetch/config";
}
