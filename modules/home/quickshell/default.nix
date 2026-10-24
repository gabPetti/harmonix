{ pkgs, inputs, vars, ... }:

let
  quickshell = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  # Quickshell is the whole desktop shell here: bar, popups, and the
  # application/wallpaper launcher that replaced rofi.
  home.packages = [
    quickshell
    # Backlight is the one thing the shell can't do over D-Bus; everything
    # else (audio, network, bluetooth, battery) goes through PipeWire,
    # NetworkManager, BlueZ and UPower directly.
    pkgs.brightnessctl
  ];

  harmonix.configLinks."quickshell" = "quickshell";

  systemd.user.services.quickshell = {
    Unit = {
      Description = "Quickshell desktop shell";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      # The wallpaper picker reads its directory from here, so the path still
      # follows vars.repoPath instead of being hardcoded in QML.
      Environment = [ "HARMONIX_WALLPAPERS=${vars.repoPath}/wallpapers" ];
      ExecStart = "${quickshell}/bin/quickshell -c harmonix";
      Restart = "on-failure";
    };
  };
}
