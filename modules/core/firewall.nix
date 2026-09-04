{ lib, ... }:

{
  networking.firewall = {
    enable = true;

    # Deny unsolicited incoming connections by default.
    # Outgoing connections are allowed.
    allowedTCPPorts = [
      22 # SSH
    ];

    allowedUDPPorts = [
      # Add UDP ports here when needed, for example:
      # 51820 # WireGuard
    ];

    # Allow traffic from trusted local networks.
    trustedInterfaces = [
      # "tailscale0"
      # "wg0"
    ];

    # Optional: allow specific services instead of manually listing ports.
    # allowedTCPPortRanges = [
    #   { from = 8000; to = 8010; }
    # ];

    # Optional logging; useful for troubleshooting blocked traffic.
    logRefusedConnections = true;
  };
}
