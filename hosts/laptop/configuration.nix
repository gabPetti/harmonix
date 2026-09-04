# manual page accessible by running ‘nixos-help’.
{ config, pkgs, ... }:

{
  networking.hostName = "laptop";

  imports = [
    ./hardware-configuration.nix
    ../../users/default.nix
    ../../modules/core/default.nix
    ../../modules/system/gnome.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run: $ nix search wget
  environment.systemPackages = with pkgs; [
    fastfetch
    vim
  ];

  system.stateVersion = "26.11";
}
