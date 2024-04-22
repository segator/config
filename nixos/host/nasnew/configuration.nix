{ inputs, config, pkgs, nixpkgs, lib, ... }:
{
        imports = [    
                ./disk-config.nix      
                ../../modules/common.nix
                ../../modules/nix
                ../../modules/sshd    

                ../../modules/grafana-agent
                ../../users/segator
                ../../users/daga12g
                ../../users/carles
                ./users.nix

                ./nextcloud.nix
                ./samba.nix
                ./nfs.nix
                ./backup.nix
        ];


        boot.loader.grub = {
        # no need to set devices, disko will add all devices that have a EF02 partition to the list already
        # devices = [ ];
        efiSupport = true;
        efiInstallAsRemovable = true;
        };

        networking.hostName = "nasnew";
        system.stateVersion = "23.11";

        environment.systemPackages = with pkgs; [
                vim git
        ];

        networking.firewall.enable = true;
        # Auto update
        system.autoUpgrade.enable = true;
}

