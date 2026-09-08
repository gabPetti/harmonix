{ pkgs, ... }:

{
  # Install Yazi and CLI preview tools
  home.packages = with pkgs; [
    yazi             # The file manager
    ffmpegthumbnailer # Video thumbnail generation
    p7zip            # Archive previews (.zip, .7z, etc.)
    jq               # JSON previewing
    poppler          # PDF previewing
    fd               # Fast file searching
    ripgrep          # Fast content searching
    fzf              # Fuzzy filtering
    zoxide           # Smart directory jump integration
  ];

  # Enable the official Home Manager Yazi module (manages yazi.toml configs)
  programs.yazi = {
    enable = true;
    enableBashIntegration = true; # Changes shell directory on exit
    enableZshIntegration = true;  # (If using zsh)
  };
}
