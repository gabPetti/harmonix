{ pkgs, config, ... }:

{
  programs.zathura = {
    enable = true;
    options = {
      selection-clipboard = "clipboard";
      recolor = "true"; # Toggle dark mode dynamically
    };
  };
}
