{ inputs, config, pkgs, nixpkgs, lib, ... }:
{
        imports = [          
      ../../modules/common.nix
      ../../modules/nix
      ../../modules/gnome      
      ../../modules/fwupd  
      ../../modules/sshd      

      ../../users/segator
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

