{ config, pkgs, ... }:

{
  programs.hyprland = {
    enable = true;
    withUWSM = false;
    #package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland; #hyprland-git
    #portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland; #xdph-git

    portalPackage = pkgs.xdg-desktop-portal-hyprland; # xdph none git
    xwayland.enable = true;
  };

  environment.systemPackages = with pkgs; [
    kitty
    rofi
    hyprpaper
    hyprlock
    brightnessctl
  ];
}
