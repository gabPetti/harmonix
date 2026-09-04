{
  description = "System configuration flake for my laptop";

  inputs = {
    # Pin to nixos-unstable or nixos-24.11 for stable channels
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations.laptop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      # Propagate flake inputs to downstream modules
      specialArgs = { inherit inputs; };

      modules = [
        # Host-specific OS configuration
        ./hosts/laptop/configuration.nix

	      # Home Manager as a NixOS module
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users = {
            gabpetti = import ./users/gabpetti/home.nix;
            gargaroth = import ./users/gargaroth/home.nix;
          };
        }
      ];
    };
  };
}
