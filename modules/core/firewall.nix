{ ... }:

{
  networking.firewall = {
    enable = true;

    # Deny unsolicited incoming connections by default.
    # Outgoing connections are allowed.
    allowedTCPPorts = [ ];
    allowedUDPPorts = [ ];

    # Interfaces exempted from the rules above, for trusted overlay networks
    # such as tailscale0 or wg0.
    trustedInterfaces = [ ];

    # Useful when troubleshooting traffic that is being dropped.
    logRefusedConnections = true;
  };
}
