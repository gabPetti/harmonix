# Folder-local Python 2 environment: `nix-shell` in this directory.
#
# python2 was removed from nixpkgs on 2026-05-03 (end of life), so this pins
# nixos-24.05 just for this shell instead of touching the flake's nixpkgs.
# It is also marked insecure there, hence permittedInsecurePackages.
let
  pkgs = import
    (builtins.fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/b134951a4c9f3c995fd7be05f3243f8ecd65d798.tar.gz";
      sha256 = "0zydsqiaz8qi4zd63zsb2gij2p614cgkcaisnk11wjy3nmiq0x1s";
    })
    { config.permittedInsecurePackages = [ "python-2.7.18.8" ]; };
in
pkgs.mkShell {
  packages = [ pkgs.python2 ];
}
