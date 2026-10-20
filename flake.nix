{
  description = "Harmonix: brain-machine operating system";

  inputs = {
    # Pin to nixos-unstable or nixos-24.11 for stable channels
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      # Install-specific values (username, hostname, checkout path). Modules
      # read these instead of hardcoding them -- see vars.nix.
      vars = import ./vars.nix;
    in
    {
      nixosConfigurations.${vars.hostName} = nixpkgs.lib.nixosSystem {
        inherit (vars) system;

        # Propagate flake inputs and install-specific values to downstream modules
        specialArgs = { inherit inputs vars; };

        modules = [
          # Host-specific OS configuration
          ./hosts/${vars.hostName}/configuration.nix

          # Home Manager as a NixOS module
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            # Home Manager evaluates with its own argument set, so `vars` has to
            # be handed over here in addition to specialArgs above.
            home-manager.extraSpecialArgs = { inherit inputs vars; };

            home-manager.users.${vars.username} =
              import ./users/${vars.username}/home.nix;
          }
        ];
      };
    };
}
