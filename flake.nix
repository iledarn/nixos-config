{
  description = "NixOS configuration";

  inputs = {
    nixpkgs-23-11.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs-24-11.url = "github:NixOS/nixpkgs/nixos-24.11";
    home-manager-23-11 = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs-23-11";
    };
    home-manager-24-11 = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs-24-11";
    };
    hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs = inputs @ {
    self,
    nixpkgs-23-11,
    nixpkgs-24-11,
    home-manager-23-11,
    home-manager-24-11,
    ...
  }: {
    nixosConfigurations = 
    let
      mkSystem = { hostname, username, nixpkgsInput, homeManagerInput, stateVersion }: nixpkgsInput.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit hostname username;
        };
        modules = [
          ./common-configuration.nix
          homeManagerInput.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${username} = import ./home.nix;
            home-manager.extraSpecialArgs = {
              inherit username stateVersion;  # This makes username available in home.nix
            };
          }
        ];
      };
    in 
    {
      scnsoft = mkSystem {
        hostname = "scnsoft";
        username = "ildar";
        nixpkgsInput = nixpkgs-23-11;
        homeManagerInput = home-manager-23-11;
        stateVersion = "23.11";
      };

      kaertech = mkSystem {
        hostname = "kaertech";
        username = "ildar";
        nixpkgsInput = nixpkgs-23-11;
        homeManagerInput = home-manager-23-11;
        stateVersion = "23.11";
      };

      gram = mkSystem {
        hostname = "gram";
        username = "ildarn";
        nixpkgsInput = nixpkgs-24-11;
        homeManagerInput = home-manager-24-11;
        stateVersion = "24.11";
      };
    };

    formatter.x86_64-linux = nixpkgs-24-11.legacyPackages.x86_64-linux.alejandra;
  };
}
