{ pkgs, ... }:

{
  # NetworkManager speaks no VPN protocol itself -- each one is a plugin that
  # registers a D-Bus service the `vpn.service-type` of a profile names. This
  # is also what puts the VPN pages in nm-applet/GNOME and what lets `nmcli
  # connection import type openvpn` read an .ovpn at all.
  networking.networkmanager.plugins = [ pkgs.networkmanager-openvpn ];

  # Profiles live in modules/core/network.nix alongside the wifi ones, since
  # they share the `.env` substitution that keeps credentials out of git.
}
