{ vars, ... }:

{
  networking.hostName = vars.hostName;

  imports = [
    ./hardware-configuration.nix
    ../../users/default.nix
    ../../modules/core/default.nix
    ../../modules/system/hyprland.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "26.11";
}
