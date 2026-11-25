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

    # Socket-activated instead of started at boot: the daemon is only needed
    # while a container is actually running, and dockerd plus containerd sit
    # on ~130MB of RSS the rest of the time. The first `docker` command pays
    # a second of startup; nothing else changes.
    virtualisation.docker.enableOnBoot = false;
    virtualisation.libvirtd.enable = cfg.libvirtd.enable;
    virtualisation.vmware.host.enable = cfg.vmware.enable;

    # The kernel's aggregate module tree now concatenates a per-module signing
    # certificate (`<mod>.ko.cer`) for every out-of-tree module. The VMware ones
    # build through VMware's own makefiles and emit bare `.ko` files, so that
    # merge step fails the whole modules derivation. Module signatures are not
    # enforced on this host, so an empty certificate beside each module is
    # enough to satisfy it. Drop this once the package ships them upstream.
    boot.kernelPackages = lib.mkIf cfg.vmware.enable (
      pkgs.linuxPackages.extend (_: kprev: {
        vmware = kprev.vmware.overrideAttrs (prevAttrs: {
          postInstall = (prevAttrs.postInstall or "") + ''
            for ko in "$out"/lib/modules/*/misc/*.ko; do
              : > "$ko.cer"
            done
          '';
        });
      })
    );

    # docker-compose ships separately from the daemon, so it follows the same
    # toggle instead of being installed unconditionally.
    environment.systemPackages = lib.optional cfg.docker.enable pkgs.docker-compose;
  };
}
