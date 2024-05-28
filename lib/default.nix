{inputs,...}:
let
    default_system = "x86_64-linux";
    linuxSystems =  [
      "aarch64-linux"     
      "x86_64-linux"
    ];
    systems = 
      linuxSystems ++ 
      [
      "aarch64-darwin"
      ];  
    overlays = map (name: (import ../overlays/${name})) (builtins.attrNames (builtins.readDir ../overlays)); 
    configureNixpkgs = system: (import inputs.nixpkgs { 
      inherit system;
      config.allowUnfree = true;
      inherit overlays;
    });
in
{    

    mkHome = userHostname: attrs @ {system ? default_system,modules ? []}:
      let
        pkgs = configureNixpkgs system;
        user = pkgs.lib.head(pkgs.lib.splitString "@" userHostname);
        hostname = pkgs.lib.last(pkgs.lib.splitString "@" userHostname);
      in
      inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = modules ++ [  
          inputs.sops-nix.homeManagerModules.sops        
          ../home-manager/configuration/${user}/home.nix
          ../home-manager/configuration/${user}/host/${hostname}.nix
          ];
      };

    mkDarwinSystem = hostname: attrs @ {system ? default_system, modules ? [], ...}:
      inputs.nix-darwin.lib.darwinSystem {
        specialArgs = { 
          inherit inputs;
          pkgs = configureNixpkgs system;
        };
        system = "aarch64-darwin";
        modules = modules ++ [ ../darwin/host/${hostname}/configuration.nix];
      };

    mkNixosSystem = hostname: attrs @ {
      system ? default_system,
      modules ? [],
      ...}:

      inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { 
          inherit inputs;
          pkgs = configureNixpkgs system;
        };          
        modules = modules ++ [                       
          inputs.sops-nix.nixosModules.sops
          ../nixos/host/${hostname}/configuration.nix
          ({
            networking.hostName = hostname;
          })
        ];
      };
    
    aarch64_darwin_pkgs = import inputs.nixpkgs {
      system = "aarch64-darwin";
      config.allowUnfree = true;
      inherit overlays;
    };
    forLinuxSystems = inputs.nixpkgs.lib.genAttrs linuxSystems;
    forAllSystems = inputs.nixpkgs.lib.genAttrs systems;
}