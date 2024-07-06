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
              deploy-rs,
              ... } @ inputs:
  let
    libx = import ./lib { inherit inputs; };
  in {
    # Nixos Systems
    nixosConfigurations = {
        fury = libx.mkNixosSystem "fury" { system = "x86_64-linux"; };
        xps15 = libx.mkNixosSystem "xps15" { system = "x86_64-linux"; };
        seganas = libx.mkNixosSystem "seganas" { 
          system = "x86_64-linux";    
          modules = [
            disko.nixosModules.disko
            impermanence.nixosModules.impermanence
          ];
        };
        vps1 = libx.mkNixosSystem "vps1" { 
          system = "x86_64-linux";    
          modules = [
            disko.nixosModules.disko
            impermanence.nixosModules.impermanence
          ];
        };
    };              

    # MacOS systems
    darwinConfigurations = {
      "aymerici-4DVF0G" = libx.mkDarwinSystem "mbp_m1" {
        system = "aarch64-darwin";
      };
    };

    # User configurations
    homeConfigurations = {
      "aymerici@fury" = libx.mkHome "aymerici@fury" { system = "x86_64-linux"; };
      "segator@fury" = libx.mkHome "segator@fury" { system = "x86_64-linux"; };
      "aymerici@xps15" = libx.mkHome "aymerici@xps15" { system = "x86_64-linux"; };
      "aymerici@aymerici-4DVF0G" = libx.mkHome "aymerici@aymerici-4DVF0G" { system = "aarch64-darwin"; };
    };

    devShells = libx.forAllSystems (system: 
      let pkgs = nixpkgs.legacyPackages.${system};
      in import ./shell.nix { inherit pkgs;}
    );

    packages = libx.forLinuxSystems (system:
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
        #Todo temporary disable it due a bug https://github.com/nix-community/nixos-images/issues/249
        # kexec-installer-nixos = kexec-installer [
        #     ( import ./nixos/modules/zfs/sse4-support.nix)
        #   ];
      }    
    );
    deploy.nodes = {
      seganas = libx.mkDeploy {
        inherit (self) nixosConfigurations;
        hostname = "192.168.0.110";
        configuration = "seganas";
      };
      vps1 = libx.mkDeploy {
        inherit (self) nixosConfigurations;
        hostname = "157.90.238.117";
        configuration = "vps1";
      };
    };


    # This is highly advised, and will prevent many possible mistakes
    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

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

      impermanence.url = "github:nix-community/impermanence";

      nixos-images.url = "github:nix-community/nixos-images";

      deploy-rs.url = "github:serokell/deploy-rs";
  };
}