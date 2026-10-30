{
  description = "fearless main flake";

  nixConfig = {
    extra-substituters = [ "https://cachix.org" ];
    extra-trusted-public-keys = [ "umbriel.cachix.org-1:JfNq/2yg2S6D6z4Z2dVSZrZlDPQTKtexB6GAVLD98nw=" ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # ADD THE DISKO INPUT COMPONENT HERE
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    umbriel.url = "github:noctalia-dev/umbriel";
    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, disko, umbriel, noctalia, home-manager, ... }@inputs: {
    nixosConfigurations.warhammer = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        # IMPORT THE DISKO MODULE AND YOUR DISKO TARGET FILE HERE
        disko.nixosModules.disko
        ./disko-config.nix

        ./configuration.nix
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.fearless = import ./home.nix;
        }
      ];
    };
  };
}
