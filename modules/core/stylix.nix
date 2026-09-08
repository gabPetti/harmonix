{ pkgs, inputs, ... }:

{
  stylix = {
    enable = true;

    # Pass a local image path or color scheme
    image = ../../wallpapers/altos-adventure-vibe.png;
    polarity = "dark"; # "dark", "light", or "either"

    # base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";
  };
}
