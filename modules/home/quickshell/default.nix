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
    # The wallpaper script's `fetch`: Wallhaven's search API over curl, read
    # with jq. Everything else it needs (hyprpaper, matugen) comes from the
    # modules that own those.
    pkgs.curl
    pkgs.jq
    # The bar's music visualizer. Quickshell's PipeWire bindings expose
    # devices and volumes but not samples, so the spectrum has to come from
    # something that taps the sink monitor itself (scripts/visualizer).
    pkgs.cava
    # notify-send, for the pomodoro timer's end-of-phase notification
    # (services/Pomodoro.qml) and the Claude voice pill's replies. swaync is
    # the daemon that renders them.
    pkgs.libnotify
    # The Claude voice pill (scripts/claude-voice): speech in through
    # whisper, the answer back out through piper. Neither ships weights --
    # the script downloads both models to ~/.cache/harmonix/voice on first
    # use, rather than pinning ~200MB of them into every generation.
    pkgs.whisper-cpp
    pkgs.piper-tts
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
