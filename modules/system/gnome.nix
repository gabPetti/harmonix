{ pkgs, ... }:

{
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "br";
    variant = "";
  };

  environment.systemPackages = with pkgs; [
    gnome-tweaks
  ];

  # Enable touchpad support (enabled default in most desktopManager). services.xserver.libinput.enable = true;
}
