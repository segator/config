{
  description = "Segator NixOS Configuration";

  outputs = { self, 
              nixpkgs,
              nix-darwin, 
              home-manager, 
              sops-nix, 
              krew2nix, 
              disko, 
              impermanence,
              #deploy-rs,
              ... } @ inputs:
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
            "${nixpkgs}/nixos/modules/virtualisation/proxmox-lxc.nix"   
            ./nixos/host/nasnew/configuration.nix     
            # Home manager
            #sops-nix.homeManagerModules.sops
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
            #./home-manager/configuration/segator/home.nix
            #./home-manager/configuration/segator/host/nas.nix
            #{ nixpkgs.config.allowUnfree = true; }       
          ];
        };
        bootstrap-iso = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [            
            (nixpkgs
              + "/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix")
            (nixpkgs + "/nixos/modules/installer/cd-dvd/channel.nix")
            ({ pkgs, ... }: {
              systemd.services.sshd.wantedBy =
                pkgs.lib.mkForce [ "multi-user.target" ];
              users.users.root.openssh.authorizedKeys.keys = [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID5vRrC3yycYEP9GoKk4nm9iTf9aFMb0pAyKbp5rcEkW segator"
                "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCSqoWu0J6MkjN5F6FWt3rho4kfFv9/9/4RluZC/Ot2n6cQs5wJ5EsEkwQ54noXhky2Zqhhtw28u0ZT9aGGJz+0Gr/6USsyi7xp7u0zmGdjmNx6SO+9NHSOUg4r38zr8aAJSnJHbhz0blKuASnQi5yNp4eYr/WxUs+L4tFwfiktb6cmKQ3S6AJiduFBEx6mySOPkGDXG+Vxz9UfYBZwuGUI6w9jjUoteo4NA3nr8rYTh1O3mdvLsMkokpzqbNPF9b9CY8z6qFtyiBqaz6ob+xe4AGIxUmng7dDGJiUAoYPALpScJSeQf3Kqa/RGkFqZO66tROm1kDZB9loOId/E9Q9ml19cguEdcPPo6QFkTj1gl3Q/I0JZ6oqtQmctPEEW8hw/Ggi4qCZAiz1JmXp4FnVl4JH/MWq265GcnYvJNs1DbuydAONJ1KbnD4MW8yor41or5+mvLbgasWgwzUmlRGZFrqojIINE3q5eQ0XvxR+xxODFLvfjWjZBoRqMayVU/lU= aymerici"
              ];
              isoImage.squashfsCompression = "gzip -Xcompression-level 1";
              networking = {
                usePredictableInterfaceNames = false;
                useDHCP = true;
                nameservers = [ "8.8.8.8" ];
              };
            })
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
    
  };

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

      disko.url = "github:nix-community/disko";
      disko.inputs.nixpkgs.follows = "nixpkgs";

      impermanence.url = "github:nix-community/impermanence"; #/create-needed-for-boot

      #deploy-rs.url = "github:serokell/deploy-rs";
  };
}