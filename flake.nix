{
  description = "fearless main flake";

  inputs = {
    # Pristine rolling unstable branch
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Wayland Compositor
    umbriel.url = "github:noctalia-dev/umbriel";

    # Desktop Shell
    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
  };


    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, umbriel, noctalia, home-manager, ... }@inputs: {
    nixosConfigurations.your-hostname = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        # ... your other system modules
      ];
    };
  };
}
