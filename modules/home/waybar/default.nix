{ config, pkgs, symlinkRoot, ... }:

let
  link = config.lib.file.mkOutOfStoreSymlink;
  toSrcFile = name: "${symlinkRoot}/${name}";
in
{
  home.file.".config/waybar".source = link "/home/gabpetti/harmonix/modules/home/waybar/waybar";
}
