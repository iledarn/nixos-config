{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
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
    nix-flatpak,
    zen-browser,
    sops-nix,
    ...
  }: let
    system = "x86_64-linux";

    # Unstable pkgs set for selected user tools
    pkgsUnstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };

    mkSystem = {
      hostname,
      username,
      stateVersion,
    }:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit hostname username pkgsUnstable stateVersion;
        };
        modules = [
          ./common-configuration.nix
          nix-flatpak.nixosModules.nix-flatpak
          home-manager.nixosModules.home-manager
          inputs.sops-nix.nixosModules.sops
          {
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "bak";
            home-manager.users.${username} = import ./home.nix;
            home-manager.extraSpecialArgs = {
              inherit username stateVersion pkgsUnstable;
              inherit (inputs) sops-nix zen-browser;
            };
          }
        ];
      };
  in {
    nixosConfigurations = {
      gram990 = mkSystem {
        hostname = "gram990";
        username = "iledarn";
        stateVersion = "25.05";
      };

      p171g = mkSystem {
        hostname = "p171g";
        username = "ildar";
        stateVersion = "25.05";
      };
    };

    formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;
  };
}
