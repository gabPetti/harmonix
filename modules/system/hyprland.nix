{ config, pkgs, ... }:

{
  services.power-profiles-daemon.enable = true;

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    #package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland; #hyprland-git
    #portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland; #xdph-git

    portalPackage = pkgs.xdg-desktop-portal-hyprland; # xdph none git
    xwayland.enable = true;
  };

  environment.systemPackages = with pkgs; [
    kitty
    hyprpaper
    hyprlock
    brightnessctl
  ];
}
