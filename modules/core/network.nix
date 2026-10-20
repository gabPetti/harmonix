_:

{
  networking.networkmanager.enable = true;
  environment.etc."eduroam/cacert.crt".source = ./eduroam-cacert.crt;
  networking.networkmanager.ensureProfiles = {
    environmentFiles = [
      "/home/gabpetti/harmonix/.env"
    ];

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
        identity = "ist1120691@tecnico.ulisboa.pt";
        anonymous-identity = "anonymous@tecnico.ulisboa.pt";
        ca-cert = "/etc/eduroam/cacert.crt";
        password = "$EDUROAM_PASSWORD";
      };
      ipv4.method = "auto";
      ipv6.method = "auto";
    };
  };
}
