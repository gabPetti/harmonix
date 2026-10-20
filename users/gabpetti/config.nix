{ config, lib, pkgs, vars, ... }:

let
  virt = config.harmonix.virtualisation;
in
{
  users.users.${vars.username} = {
    isNormalUser = true;
    description = vars.fullName;

    # The docker/libvirtd groups only exist when their daemon is enabled, so
    # they follow the toggles in modules/core/virtualization.nix rather than
    # being listed unconditionally.
    extraGroups = [ "networkmanager" "wheel" "input" ]
      ++ lib.optional virt.docker.enable "docker"
      ++ lib.optional virt.libvirtd.enable "libvirtd";

    shell = pkgs.zsh;
    packages = with pkgs; [
      vim
      unzip
      psmisc
      discord-ptb
      gh
      nodejs
      python3
      python3Packages.pip
      python3Packages.holidays
      jdk
      maven
      libnotify
      gnuplot
      btop
      google-cloud-sdk
      vagrant
      steam-run
      aider-chat
      claude-code
    ];
  };
}
