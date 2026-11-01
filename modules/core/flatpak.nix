{ pkgs, ... }:

{
  # Sober (Roblox client) has no Nix package, so Flatpak is the only way in.
  services.flatpak.enable = true;

  # nixpkgs' flatpak module has no declarative remotes/apps, so the state it
  # needs is reconciled on every boot instead. `--noninteractive` keeps it from
  # blocking on prompts, and both steps are idempotent.
  systemd.services.flatpak-managed-install = {
    description = "Reconcile declaratively managed Flatpak remotes and apps";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    path = [ pkgs.flatpak ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      flatpak remote-add --if-not-exists flathub \
        https://dl.flathub.org/repo/flathub.flatpakrepo
      flatpak install --assumeyes --noninteractive flathub org.vinegarhq.Sober
    '';
  };
}
