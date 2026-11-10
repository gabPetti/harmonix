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
    options = "--delete-older-than 2d";
  };

  nixpkgs.config.allowUnfree = true;
  nix.settings.auto-optimise-store = true;
  system.stateVersion = "26.11";
}
