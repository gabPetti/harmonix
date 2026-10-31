{ pkgs, ... }:

{
  fonts = {
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.symbols-only
      noto-fonts-color-emoji
      # Variable (FILL/GRAD/opsz/wght) Material Symbols, which is what the
      # quickshell bar's resource dials draw their glyphs from. Ligature
      # based: the text "memory" *is* the icon, so the family has to be
      # installed or the dials render the word instead.
      material-symbols
    ];

    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "JetBrainsMono Nerd Font" "Noto Color Emoji" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
