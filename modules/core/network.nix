{ vars, ... }:

{
  networking.networkmanager.enable = true;

  # Public CA bundle used to validate the eduroam RADIUS server. Not a secret.
  environment.etc."eduroam/cacert.crt".source = ./eduroam-cacert.crt;

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
  };
}
