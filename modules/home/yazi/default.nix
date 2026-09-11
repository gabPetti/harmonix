{ config, pkgs, ... }:

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

  xdg.configFile."yazi".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/harmonix/modules/home/yazi/config";
}
