{
  description = "System configuration flake for my laptop";

  inputs = {
    # Pin to nixos-unstable (or use nixos-24.05 / nixos-24.11 for stable channels)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations = {
      # Target hostname matching your directory convention
      laptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        
        # Propagate flake inputs to downstream modules
        specialArgs = { inherit inputs; };

        modules = [
          # Hardware abstraction layer
          ./hosts/laptop/hardware-configuration.nix

          # Host-specific OS configuration
          ./hosts/laptop/configuration.nix

          # Shared/reusable module imports (example: ./modules/desktop.nix or inline imports)
        ];
      };
    };
  };
}
