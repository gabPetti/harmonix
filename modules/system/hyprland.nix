{ pkgs, ... }:

{
  services.power-profiles-daemon.enable = true;

  # UPower backs the bar's battery readout; without it Quickshell has no
  # battery to show at all.
  services.upower.enable = true;

  # The PAM service the Quickshell lock screen authenticates against
  # (quickshell/config/harmonix/services/LockState.qml, which names
  # /etc/pam.d/harmonix-lock). Defaults are enough: an auth stack of pam_unix
  # then pam_deny, which is exactly "the account's own password or nothing".
  #
  # Its own service rather than borrowing login's, because a lock
  # authenticates a session that is already open -- it should not inherit
  # whatever a later fingerprint reader or autologin change does to the login
  # stack.
  security.pam.services.harmonix-lock = { };

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
