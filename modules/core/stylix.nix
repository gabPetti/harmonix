{ pkgs, inputs, ... }:

{
  stylix = {
    enable = true;

    # Pass a local image path or color scheme
    image = ../../wallpapers/altos-adventure-vibe.png;
    polarity = "dark"; # "dark", "light", or "either"

    cursor = {
      package = pkgs.phinger-cursors;
      name = "phinger-cursors-dark";
      size = 24; # Standard sizes: 16, 24, 32, 48
    };
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
  };
}
