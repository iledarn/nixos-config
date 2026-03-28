{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    sops-nix,
    ...
  }: {
    nixosConfigurations = let
      system = "x86_64-linux";

      # Unstable pkgs set for selected user tools
      pkgsUnstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      gram990 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          hostname = "gram990";
          username = "iledarn";
          inherit pkgsUnstable;
        };
        modules = [
          ./common-configuration.nix
          home-manager.nixosModules.home-manager
          inputs.sops-nix.nixosModules.sops
          {
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "bak";
            home-manager.users.iledarn = import ./home.nix;
            home-manager.extraSpecialArgs = {
              username = "iledarn";
              stateVersion = "25.05";
              inherit pkgsUnstable;
              inherit (inputs) sops-nix;
            };
          }
        ];
      };
    };

    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
  };
}
