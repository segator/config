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
      
      krew2nix.url = "github:eigengrau/krew2nix";
      krew2nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, sops-nix, krew2nix,  ... } @ inputs:
  let
    systems = [
      "aarch64-linux"     
      "x86_64-linux"
      "aarch64-darwin"
    ];    
    x86_64_pkgs = import nixpkgs { 
      system = "x86_64-linux";
      config.allowUnfree = true;
    };
    aarch64_darwin_pkgs = import nixpkgs {
      system = "aarch64-darwin";
      config.allowUnfree = true;
    };
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    nixosConfigurations = {
         fury = nixpkgs.lib.nixosSystem {
          specialArgs = { 
            inherit inputs;
            pkgs = x86_64_pkgs;
          };
          system = "x86_64-linux";
          modules = [            
            sops-nix.nixosModules.sops
            ./nixos/host/fury/configuration.nix
          ];
        };
        xps15 = nixpkgs.lib.nixosSystem {
          specialArgs = { 
            inherit inputs;
            pkgs = x86_64_pkgs;
          };       
          system = "x86_64-linux";   
          modules = [
            sops-nix.nixosModules.sops
            ./nixos/host/xps15/configuration.nix
          ];
        };
        nasnew = nixpkgs.lib.nixosSystem {
          specialArgs = { 
            inherit inputs;
            pkgs = x86_64_pkgs;
          };
          system = "x86_64-linux";
          modules = [       
            sops-nix.nixosModules.sops  
            "${nixpkgs}/nixos/modules/virtualisation/proxmox-lxc.nix"   
            ./nixos/host/nasnew/configuration.nix            
          ];
        };
        
    };
    darwinConfigurations."aymerici-4DVF0G" = nix-darwin.lib.darwinSystem {
      specialArgs = { 
        inherit inputs;
        pkgs = aarch64_darwin_pkgs;
      };
      system = "aarch64-darwin";
      modules = [ ./darwin/host/mbp_m1/configuration.nix ];
    };
    homeConfigurations = {
      "aymerici@fury" = home-manager.lib.homeManagerConfiguration {
        pkgs = x86_64_pkgs;
        modules = [  
          sops-nix.homeManagerModules.sops        
          ./home-manager/configuration/aymerici/home.nix
          ./home-manager/configuration/aymerici/host/fury.nix
          { nixpkgs.config.allowUnfree = true; }
          ];
      };
      "segator@fury" = home-manager.lib.homeManagerConfiguration {
        pkgs = x86_64_pkgs;
        modules = [
          sops-nix.homeManagerModules.sops
          ./home-manager/configuration/segator/home.nix
          ./home-manager/configuration/segator/host/fury.nix
          { nixpkgs.config.allowUnfree = true; }
          ];
      };
      "aymerici@xps15" = home-manager.lib.homeManagerConfiguration {
        extraSpecialArgs = { 
         inherit inputs;
        };
        pkgs = x86_64_pkgs;
        modules = [ 
          sops-nix.homeManagerModules.sops
          ./home-manager/configuration/aymerici/home.nix
          ./home-manager/configuration/aymerici/host/xps15.nix
          { nixpkgs.config.allowUnfree = true; }
          ];
      };

      "aymerici@aymerici-4DVF0G" = home-manager.lib.homeManagerConfiguration {
        pkgs = aarch64_darwin_pkgs;
        modules = [ 
          sops-nix.homeManagerModules.sops
          ./home-manager/configuration/aymerici/home.nix
          ./home-manager/configuration/aymerici/host/aymerici-4DVF0G.nix
          { nixpkgs.config.allowUnfree = true; }
          ];
      };

      "aymerici@nasnew" = home-manager.lib.homeManagerConfiguration {
        pkgs = x86_64_pkgs;
        modules = [ 
          sops-nix.homeManagerModules.sops
          ./home-manager/configuration/aymerici/home.nix
          ./home-manager/configuration/aymerici/host/nasnew.nix
          { nixpkgs.config.allowUnfree = true; }
         ];
      };
    };

    devShells = forAllSystems (system: import ./shell.nix nixpkgs.legacyPackages.${system});
    
  };
}