{ inputs, config, pkgs, nixpkgs, lib, ... }:
{
        imports = [          
                ../../modules/common.nix
                ../../modules/nix
                ../../modules/sshd    

                ../../modules/grafana-agent
                ../../users/segator
                ../../users/daga12g
                ../../users/carles
                ./users.nix

                #./nextcloud.nix
                ./samba.nix
                ./backup.nix
        ];

        proxmoxLXC = {
                # manageNetwork = false;
                # privileged = false;
        };
        networking.hostName = "nasnew";
        system.stateVersion = "23.05";

        environment.systemPackages = with pkgs; [
                vim git
        ];

        # Auto update
        system.autoUpgrade.enable = true;
}

