{ pkgs, lib, config, ... }:

{
  options.modules.swayosd = {
    enable = lib.mkEnableOption "SwayOSD on-screen display daemon";
  };

  config = lib.mkIf config.modules.swayosd.enable {
    home.packages = with pkgs; [
      swayosd
    ];

    # Enable SwayOSD systemd user service natively provided by Home Manager
    services.swayosd = {
      enable = true;
      topMargin = 0.05;
    };

    # Custom CSS configuration for minimal badge styling
    xdg.configFile."swayosd/style.css".text = ''
      window {
        background-color: rgba(20, 20, 20, 0.85);
        border-radius: 24px;
        border: 1px solid rgba(255, 255, 255, 0.1);
        /* padding: 8px 8px; */
      }

      label {
        color: #ffffff;
        font-family: "JetBrainsMono Nerd Font", monospace;
        font-size: 48px;
        font-weight: bold;
      }

      progress, image {
        color: #89b4fa;
      }
    '';
  };
}
