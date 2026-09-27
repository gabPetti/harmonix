{ pkgs, ... }:

{
  virtualisation.docker.enable = true;

  # Install docker-compose CLI plugin / binary
  environment.systemPackages = with pkgs; [
    docker-compose
  ];

  virtualisation.vmware.host.enable = true;
  virtualisation.libvirtd.enable = true;
}
