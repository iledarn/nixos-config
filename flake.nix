{
  description = "NixOS configuration";

  inputs = {
    nixpkgs-23-11.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs-24-11.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-25-05.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager-23-11 = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs-23-11";
    };
    home-manager-24-11 = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs-24-11";
    };
    home-manager-25-05 = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs-25-05";
    };
    hyprland.url = "github:hyprwm/Hyprland";
    caelestia-shell.url = "github:caelestia-dots/shell";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-25-05";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs-23-11,
    nixpkgs-24-11,
    nixpkgs-25-05,
    nixpkgs-unstable,
    home-manager-23-11,
    home-manager-24-11,
    home-manager-25-05,
    sops-nix,
    ...
  }: {
    nixosConfigurations = let
      system = "x86_64-linux";

      # Unstable pkgs set (only for codex/kiro/kiro-cli)
      pkgsUnstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true; # needed for kiro
      };

      mkSystem = {
        hostname,
        username,
        nixpkgsInput,
        homeManagerInput,
        stateVersion,
      }:
        nixpkgsInput.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit hostname username pkgsUnstable;
          };
          modules = [
            ./common-configuration.nix
            homeManagerInput.nixosModules.home-manager
            inputs.sops-nix.nixosModules.sops
            {
              home-manager.useUserPackages = true;
              # Automatically back up files that clash with Home Manager links
              home-manager.backupFileExtension = "bak";
              home-manager.sharedModules = [
                inputs."caelestia-shell".homeManagerModules.default
              ];
              home-manager.users.${username} = import ./home.nix;
              home-manager.extraSpecialArgs = {
                inherit username stateVersion pkgsUnstable; # This makes username available in home.nix
                inherit (inputs) sops-nix;
              };
            }
          ];
        };
    in {
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
      gram990 = mkSystem {
        hostname = "gram990";
        username = "iledarn";
        nixpkgsInput = nixpkgs-25-05;
        homeManagerInput = home-manager-25-05;
        stateVersion = "25.05";
      };
    };

    formatter.x86_64-linux = nixpkgs-24-11.legacyPackages.x86_64-linux.alejandra;
  };
}
