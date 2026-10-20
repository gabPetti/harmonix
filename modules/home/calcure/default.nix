{ pkgs, ... }:

{
  home.packages = with pkgs; [
    calcure
  ];

  xdg.desktopEntries.calcure = {
    name = "Calcure";
    genericName = "Calendar & Tasks";
    comment = "Modern TUI calendar and task manager";
    exec = "kitty -e calcure"; # Change 'kitty' to your preferred terminal (e.g. foot, alacritty)
    terminal = false; # Set to false because we explicitly pass the terminal binary in 'exec'
    icon = "office-calendar";
    categories = [ "Utility" "Calendar" ];
  };
}
