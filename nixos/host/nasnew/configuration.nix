{ inputs, config, pkgs, nixpkgs, lib, ... }:
{
        imports = [    
                ./hardware-configuration.nix
                ./disk-config.nix    
                ./persistence.nix  
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
        boot = {
          kernelPackages = pkgs.linuxPackages_6_1.extend (_: prev: {
            zfs_unstable = prev.zfs_unstable.overrideAttrs (old: {
              src = pkgs.fetchFromGitHub {
              owner = "openzfs";
              repo = "zfs";
              rev = "pull/14531/head";
              sha256 = "sha256-TaptNheaiba1FBXGW2piyZjTIiScpaWuNUGvi5SglPE=";
            };
          });
        });
        loader.grub = {
           # no need to set devices, disko will add all devices that have a EF02 partition to the list already
           # devices = [ ];
           efiSupport = true;
           efiInstallAsRemovable = true;
        };
        };
        supportedFilesystems = ["zfs"  "btrfs"];
        zfs = {
          package = pkgs.zfs_unstable;
          #forceImportRoot = true;
        };

        networking.hostName = "nasnew";
        networking.hostId = "4e98920d";
        system.stateVersion = "23.11";

        services.openssh.enable = true;

        users.users.root.openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID5vRrC3yycYEP9GoKk4nm9iTf9aFMb0pAyKbp5rcEkW segator"
        ];

        networking.firewall.enable = true;
        # Auto update
        system.autoUpgrade.enable = true;
}

