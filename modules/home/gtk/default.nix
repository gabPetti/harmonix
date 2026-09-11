{ config, pkgs, ... }:

{
  gtk = {
    enable = true;

    # Prefers dark theme for GTK3 / GTK4 apps that support color-scheme settings
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };

    # Import Matugen's dynamically generated CSS file
    gtk3.extraCss = ''
      @import url("file://${config.xdg.configHome}/gtk-3.0/matugen-colors.css");
    '';

    gtk4.extraCss = ''
      @import url("file://${config.xdg.configHome}/gtk-4.0/matugen-colors.css");
    '';
  };

  # 3. Force dark mode via XDG Desktop Portal (crucial for modern GTK4 / Libadwaita apps)
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      font-name = "JetBrainsMono Nerd Font 10";
    };
  };
}
