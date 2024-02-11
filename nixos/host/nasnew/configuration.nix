{ inputs, config, pkgs, nixpkgs, lib, ... }:
{
        imports = [          
          ../../modules/nix
        ];
        proxmoxLXC = {
                # manageNetwork = false;
                # privileged = false;
        };
        system.stateVersion = "23.05";

        environment.systemPackages = with pkgs; [
                vim git
        ];

        # Auto update
        system.autoUpgrade.enable = true;
}

