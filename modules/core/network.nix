{ vars, ... }:

{
  networking.networkmanager.enable = true;

  # Public CA bundle used to validate the eduroam RADIUS server. Not a secret.
  environment.etc."eduroam/cacert.crt".source = ./eduroam-cacert.crt;

  # The CA and tls-auth key lifted out of the <ca> and <tls-auth> blocks of
  # IST's own tecnico.ovpn (kept beside this file). NetworkManager's openvpn
  # plugin takes those two as paths, never inline, which is the only reason
  # they are separate files at all. Neither is a credential: the .ovpn is
  # handed to every student, and the tls-auth key only HMACs the control
  # channel -- the account's password is what lives in `.env`.
  environment.etc."openvpn/tecnico-ca.crt".source = ./tecnico-ca.crt;
  environment.etc."openvpn/tecnico-ta.key".source = ./tecnico-ta.key;

  networking.networkmanager.ensureProfiles = {
    # NetworkManager pipes the generated profile through envsubst before writing
    # it to /etc, so every `$VAR` below is resolved from this file at activation
    # time. Routing the identity through it as well as the password keeps
    # personal data out of both the Nix store and git history.
    environmentFiles = [ "${vars.repoPath}/.env" ];

    profiles.eduroam = {
      connection = {
        id = "eduroam";
        type = "wifi";
        permissions = "";
      };
      wifi = {
        mode = "infrastructure";
        ssid = "eduroam";
      };
      wifi-security = {
        key-mgmt = "wpa-eap";
      };
      "802-1x" = {
        eap = "peap";
        phase2-auth = "mschapv2";
        identity = "$EDUROAM_IDENTITY";
        anonymous-identity = "anonymous@tecnico.ulisboa.pt";
        ca-cert = "/etc/eduroam/cacert.crt";
        password = "$EDUROAM_PASSWORD";
      };
      ipv4.method = "auto";
      ipv6.method = "auto";
    };

    # IST's OpenVPN, as a profile rather than an `nmcli connection import` of
    # the .ovpn: imported profiles live only in /etc/NetworkManager and would
    # be lost on any machine this flake is rebuilt onto. Every setting here is
    # a line of tecnico.ovpn translated into the plugin's own key names.
    profiles.tecnico = {
      connection = {
        id = "tecnico";
        type = "vpn";
        permissions = "";
        autoconnect = false;
      };
      vpn = {
        service-type = "org.freedesktop.NetworkManager.openvpn";
        connection-type = "password";
        remote = "vpn.tecnico.ulisboa.pt";
        dev-type = "tun";
        proto-tcp = "no";
        cipher = "AES-256-CBC";
        auth = "SHA256";
        tls-version-min = "1.2";
        remote-cert-tls = "server";
        ca = "/etc/openvpn/tecnico-ca.crt";
        ta = "/etc/openvpn/tecnico-ta.key";
        ta-dir = "0";
        username = "$VPN_IST_IDENTITY";
        # 0 means "stored in this profile, for any user" -- without it
        # NetworkManager asks an agent for the password every time, and the
        # bar's toggle has no agent to ask.
        password-flags = "0";
      };
      vpn-secrets.password = "$VPN_IST_PASSWORD";
      ipv4.method = "auto";
      # The tunnel is v4-only; leaving v6 on `auto` lets traffic leak around
      # it on any network that offers v6.
      ipv6.method = "disabled";
    };
  };
}
