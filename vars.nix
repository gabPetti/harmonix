# Single source of truth for everything install-specific: who this machine
# belongs to, what it is called, and where this repo is checked out.
#
# Anything that would otherwise be a hardcoded "gabpetti" or a hardcoded
# "/home/gabpetti/harmonix" inside a module belongs here instead. These values
# reach NixOS modules through `specialArgs` and Home Manager modules through
# `extraSpecialArgs`, both wired up in flake.nix.
let
  username = "gabpetti";
  homeDirectory = "/home/${username}";
in
{
  inherit username homeDirectory;

  # Login account metadata.
  fullName = "Gabriel Petti Tavares";
  email = "gabpettidev@gmail.com";

  # Host identity. flake.nix derives both the attribute name of the
  # nixosConfiguration and the hosts/<name> path from hostName.
  hostName = "laptop";
  system = "x86_64-linux";

  # Absolute path to this checkout on the running machine.
  #
  # The out-of-store dotfile symlinks and the NetworkManager secrets file
  # resolve through this at runtime, so it has to describe the live filesystem
  # rather than the flake's /nix/store path. Relocate the checkout and this is
  # the only line that needs updating.
  repoPath = "${homeDirectory}/harmonix";
}
