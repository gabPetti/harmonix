# manual page accessible by running ‘nixos-help’.
{ config, pkgs, ... }:

{
  networking.hostName = "laptop";

  imports = [
    ./hardware-configuration.nix
    ../../users/default.nix
    ../../modules/core/default.nix
    ../../modules/system/hyprland.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "26.11";
}
