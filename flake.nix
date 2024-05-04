{
  description = "Segator NixOS Configuration";

  outputs = { self, 
              nixpkgs,
              nixpkgs-unstable-small,
              nixos-generators,
              nix-darwin, 
              home-manager, 
              sops-nix, 
              krew2nix, 
              disko, 
              impermanence,
              nixos-images,
              #deploy-rs,
              ... } @ inputs:
  let
    linuxSystems =  [
      "aarch64-linux"     
      "x86_64-linux"
    ];
    systems = 
      linuxSystems ++ 
      [
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
    forLinuxSystems =  nixpkgs.lib.genAttrs linuxSystems;
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
          #extraSpecialArgs = { inherit inputs; pkgs = x86_64_pkgs; };
          specialArgs = { 
            inherit inputs;
            pkgs = x86_64_pkgs;
          };          
          system = "x86_64-linux";
          modules = [       
            disko.nixosModules.disko
            impermanence.nixosModules.impermanence
            home-manager.nixosModules.default
            sops-nix.nixosModules.sops  
            #"${nixpkgs}/nixos/modules/virtualisation/proxmox-lxc.nix"   
            ./nixos/host/nasnew/configuration.nix     
            # Home manager
            (
              {
                home-manager = {
                  extraSpecialArgs = { inherit inputs; pkgs = x86_64_pkgs; };
                  users = {
                    "segator" = {
                      imports = [
                        sops-nix.homeManagerModules.sops
                        ./home-manager/configuration/segator/home.nix
                        #./home-manager/configuration/segator/host/nas.nix
                      ];
                    }; 
                  };
                };
              }              
            )
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

      "segator@nas" = home-manager.lib.homeManagerConfiguration {
        pkgs = x86_64_pkgs;
        modules = [ 
          sops-nix.homeManagerModules.sops
          ./home-manager/configuration/segator/home.nix
          ./home-manager/configuration/segator/host/nas.nix
          { nixpkgs.config.allowUnfree = true; }
         ];
      };
    };

    devShells = forAllSystems (system: import ./shell.nix nixpkgs.legacyPackages.${system});

    packages = forLinuxSystems (system:
      let
        pkgs = import nixpkgs-unstable-small { 
          inherit system;
          config.allowUnfree = true;
        };
        kexec-installer = modules: (pkgs.nixos (modules ++ [ inputs.nixos-images.nixosModules.kexec-installer ])).config.system.build.kexecTarball;
      in
      {
        bootstrap-iso = nixos-generators.nixosGenerate {
          inherit system;
          specialArgs = {
            pkgs= nixpkgs.legacyPackages.${system};
          };
          modules = [
            ./nixos/host/bootstrap-iso/configuration.nix
          ];
          format = "iso";
        };

        kexec-installer-nixos = kexec-installer [
            ( import ./nixos/modules/zfs/sse4-support.nix)
          ];
      }    
    );
  };

  inputs = {
      nixpkgs.url = "nixpkgs/nixos-unstable";

      # TODO seems there is a bug in latests commits for kexec builds, so we need this input rev
      nixpkgs-unstable-small.url = "nixpkgs/203fac824e2fdfed2e3a832b8123d9a64ee58b43";
      
      nixos-generators = {
        url = "github:nix-community/nixos-generators";
        inputs.nixpkgs.follows = "nixpkgs";
      };
      nixos-hardware.url = "github:NixOS/nixos-hardware/master";
      
      home-manager.url = "github:nix-community/home-manager";
      home-manager.inputs.nixpkgs.follows = "nixpkgs";
      
      hyprland.url = "github:hyprwm/Hyprland";
      
      sops-nix.url = "github:Mic92/sops-nix";
      
      nix-darwin.url = "github:LnL7/nix-darwin";
      nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
      
      krew2nix.url = "github:eigengrau/krew2nix";
      krew2nix.inputs.nixpkgs.follows = "nixpkgs";

      disko.url = "github:nix-community/disko";
      disko.inputs.nixpkgs.follows = "nixpkgs";

      impermanence.url = "github:nix-community/impermanence"; #/create-needed-for-boot

      nixos-images.url = "github:nix-community/nixos-images";

      #deploy-rs.url = "github:serokell/deploy-rs";
  };
}