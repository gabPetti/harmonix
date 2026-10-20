{ config, lib, pkgs, ... }:

let
  cfg = config.harmonix.virtualisation;
in
{
  # Three independent hypervisor stacks. They all default to on so this module
  # keeps its previous behaviour, but each can now be switched off from the host
  # config without editing this file -- they are not cheap to build or to keep
  # running, so turn off whichever you do not actually use.
  options.harmonix.virtualisation = {
    docker.enable = lib.mkEnableOption "the Docker daemon and the docker-compose CLI" // {
      default = true;
    };

    libvirtd.enable = lib.mkEnableOption "the libvirt/QEMU daemon" // {
      default = true;
    };

    vmware.enable = lib.mkEnableOption "VMware Workstation host support" // {
      default = true;
    };
  };

  config = {
    virtualisation.docker.enable = cfg.docker.enable;
    virtualisation.libvirtd.enable = cfg.libvirtd.enable;
    virtualisation.vmware.host.enable = cfg.vmware.enable;

    # docker-compose ships separately from the daemon, so it follows the same
    # toggle instead of being installed unconditionally.
    environment.systemPackages = lib.optional cfg.docker.enable pkgs.docker-compose;
  };
}
