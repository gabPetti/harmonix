{ vars, ... }:

{
  networking.hostName = vars.hostName;

  imports = [
    ./hardware-configuration.nix
    ../../users/default.nix
    ../../modules/core/default.nix
    ../../modules/system/hyprland.nix
  ];

  # No QEMU guests are defined on this host, and the legacy monolithic daemon
  # exits on its idle timeout and lands in `failed` on every boot as a result.
  # Docker and VMware stay on; see modules/core/virtualization.nix.
  harmonix.virtualisation.libvirtd.enable = false;

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
