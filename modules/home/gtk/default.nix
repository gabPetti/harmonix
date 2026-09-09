{ pkgs, ... }:

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

    # System-wide UI font declaration
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 10;
    };

    # Default fallback dark theme (Adwaita-dark is built into GTK)
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };

    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
  };

  # 3. Force dark mode via XDG Desktop Portal (crucial for modern GTK4 / Libadwaita apps)
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      font-name = "JetBrainsMono Nerd Font 10";
    };
  };
}
