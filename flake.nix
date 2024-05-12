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
    default_system = "x86_64-linux";
    overlays = map (name: (import ./overlays/${name})) (builtins.attrNames (builtins.readDir ./overlays)); 
    linuxSystems =  [
      "aarch64-linux"     
      "x86_64-linux"
    ];
    systems = 
      linuxSystems ++ 
      [
      "aarch64-darwin"
      ];    
    
    mkHome = userHostname: attrs @ {system ? default_system,modules ? []}:
      let
        user = builtins.substringBefore userHostname "@";
        hostname = builtins.substringAfter userHostname "@";
      in
      home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { 
            inherit system;
            config.allowUnfree = true;
            inherit overlays;
          };
        modules = modules ++ [  
          sops-nix.homeManagerModules.sops        
          ./home-manager/configuration/${user}/home.nix
          ./home-manager/configuration/${user}/host/${hostname}.nix
          { nixpkgs.config.allowUnfree = true; }
          ];
      };

    mkNixosSystem = hostname: attrs @ {system ? default_system, modules ? [], ...}:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { 
          inherit inputs;
          pkgs = import nixpkgs { 
            inherit system;
            config.allowUnfree = true;
            inherit overlays;
          };
        };          
        modules = modules ++ [                       
          sops-nix.nixosModules.sops
          ./nixos/host/${hostname}/configuration.nix
        ];
      };
    
    

    x86_64_pkgs = import nixpkgs { 
      system = "x86_64-linux";
      config.allowUnfree = true;
      inherit overlays;
    };
    aarch64_darwin_pkgs = import nixpkgs {
      system = "aarch64-darwin";
      config.allowUnfree = true;
      inherit overlays;
    };
    forLinuxSystems =  nixpkgs.lib.genAttrs linuxSystems;
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    nixosConfigurations = {
        fury = mkNixosSystem "fury" {
          system = "x86_64-linux";          
        };
        xps15 = mkNixosSystem "xps15" {
          system = "x86_64-linux";          
        };
        nasnew = mkNixosSystem "nasnew" {
          system = "x86_64-linux";
          modules = [
            disko.nixosModules.disko
            impermanence.nixosModules.impermanence 
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
      "aymerici@fury" = mkHome "aymerici@fury" { system = "x86_64-linux"; };
      "segator@fury" = mkHome "segator@fury" { system = "x86_64-linux"; };
      "aymerici@xps15" = mkHome "aymerici@xps15" { system = "x86_64-linux"; };
      "aymerici@aymerici-4DVF0G" = mkHome "aymerici@aymerici-4DVF0G" { system = "aarch64-darwin"; };
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