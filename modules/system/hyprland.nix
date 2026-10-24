{ pkgs, ... }:

{
  services.power-profiles-daemon.enable = true;

  # UPower backs the bar's battery readout; without it Quickshell has no
  # battery to show at all.
  services.upower.enable = true;

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    portalPackage = pkgs.xdg-desktop-portal-hyprland;
    xwayland.enable = true;
  };

  environment.systemPackages = with pkgs; [
    brightnessctl
  ];
}
