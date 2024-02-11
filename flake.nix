{
  description = "Segator NixOS Configuration";

  inputs = {
      nixpkgs.url = "nixpkgs/nixos-unstable";
      nixos-hardware.url = "github:NixOS/nixos-hardware/master";
      home-manager.url = "github:nix-community/home-manager";
      home-manager.inputs.nixpkgs.follows = "nixpkgs";
      hyprland.url = "github:hyprwm/Hyprland";
      sops-nix.url = "github:Mic92/sops-nix";
      nix-darwin.url = "github:LnL7/nix-darwin";
      nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, sops-nix, ... } @ inputs:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
    #pkgs = nixpkgs.legacyPackages.${system};
  in {
    nixosConfigurations = {
         fury = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [            
            sops-nix.nixosModules.sops
            ./nixos/host/fury/configuration.nix
          ];
        };
        xps15 = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };          
          modules = [
            sops-nix.nixosModules.sops
            ./nixos/host/xps15/configuration.nix
          ];
        };
        nasnew = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          inherit system;
          modules = [       
            sops-nix.nixosModules.sops  
            "${nixpkgs}/nixos/modules/virtualisation/proxmox-lxc.nix"   
            ./nixos/host/nasnew/configuration.nix            
          ];
        };
        
    };
    darwinConfigurations."aymerici-4DVF0G" = nix-darwin.lib.darwinSystem {
      specialArgs = { inherit inputs; };
      modules = [ ./darwin/host/mbp_m1/configuration.nix ];
    };
    homeConfigurations = {
      "aymerici@fury" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [  
          sops-nix.homeManagerModules.sops        
          ./home-manager/configuration/aymerici/home.nix
          ./home-manager/configuration/aymerici/host/fury.nix
          { nixpkgs.config.allowUnfree = true; }
          ];
      };
      "segator@fury" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          sops-nix.homeManagerModules.sops
          ./home-manager/configuration/segator/home.nix
          ./home-manager/configuration/segator/host/fury.nix
          { nixpkgs.config.allowUnfree = true; }
          ];
      };
      "aymerici@xps15" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ 
          sops-nix.homeManagerModules.sops
          ./home-manager/configuration/aymerici/home.nix
          ./home-manager/configuration/aymerici/host/xps15.nix
          { nixpkgs.config.allowUnfree = true; }
          ];
      };

      "aymerici@nasnew" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ 
          sops-nix.homeManagerModules.sops
          ./home-manager/configuration/aymerici/home.nix
          ./home-manager/configuration/aymerici/host/nasnew.nix
          { nixpkgs.config.allowUnfree = true; }
         ];
      };
    };

    devShells.${system}.default = import ./shell.nix { inherit pkgs; };
  };
}