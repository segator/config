{ lib, config, ... }:
let
in
{
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    zfs rollback -r zroot/root@empty
  '';

  disko.devices = {
    disk.main = {
      device = lib.mkDefault "/dev/sda"; 
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            size = "1M";
            type = "EF02"; # for grub MBR
          };
          ESP = {
            name = "ESP";
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          system = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "zroot";
            };
          };          
        };
      };
    };

    disk.nas = {
      device = "/dev/sdb"; # /dev/disk/by-id/ata-Samsung_SSD_860_EVO_500GB_S3Z1NB0K303456L"
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          nas = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "nas";
            };
          };          
        };
      };
    };

    zpool = {
      zroot = {
        type = "zpool";
        mode = ""; # mirror
        rootFsOptions = {
          mountpoint = "none";
          acltype = "posixacl";
          xattr = "sa";
          atime = "off";
          compression = "zstd";
          "com.sun:auto-snapshot" = "false";
          encryption = "aes-256-gcm";
          keyformat = "passphrase";
          keylocation = "file:///tmp/disk.key";
          dedup = "on";   
        };

        postCreateHook = ''
          # after disko creates the encrypted volume we switch to prompt for next boots
          zfs set keylocation="prompt" "zroot";          
        '';

        # postMountHook = ''
        #     mkdir -p /mnt/persist/system/var/lib/nixos
        #     mkdir -p /mnt/persist/system/etc/nixos
        #     mkdir -p /mnt/persist/system/var/log
        #     mkdir -p /mnt/persist/system/var/lib/systemd/coredump
        #     '';
        datasets = {
          root = {
            type = "zfs_fs";
            mountpoint = "/";
            postCreateHook = "zfs snapshot zroot/root@empty";
          };
          persist = {
            type = "zfs_fs";
            mountpoint = "/persist";
            
            options = {
             "com.sun:auto-snapshot" = "true";            
             };
          };
          nix = {
            type = "zfs_fs";
            mountpoint = "/nix";
          };
        };
      };


      nas = {
        type = "zpool";
        mode = ""; # mirror
        rootFsOptions = {
          mountpoint = "none";
          acltype = "posixacl";
          xattr = "sa";
          atime = "off";
          compression = "zstd";
          "com.sun:auto-snapshot" = "false";
          encryption = "aes-256-gcm";
          keyformat = "passphrase";
          keylocation = "file:///tmp/disk.key";
          dedup = "off";
        };

        postCreateHook = ''
          # after disko creates the encrypted volume we switch to prompt for next boots
          zfs set keylocation="prompt" "nas";          
        '';

        datasets = {
          root = {
            type = "zfs_fs";
            mountpoint = "/nas";
          };
          homes = {
            type = "zfs_fs";
            mountpoint = "/nas/homes";            
            options = {
             "com.sun:auto-snapshot" = "true";            
            };
          };
          crbmc = {
            type = "zfs_fs";
            mountpoint = "/nas/crbmc";            
            options = {
             "dedup" = "on";
             "com.sun:auto-snapshot" = "true";            
             };
          };
          photo = {
            type = "zfs_fs";
            mountpoint = "/nas/photo";            
            options = {
             "com.sun:auto-snapshot" = "true";            
             };
          };
          isaacaina = {
            type = "zfs_fs";
            mountpoint = "/nas/isaacaina";            
            options = {
             "com.sun:auto-snapshot" = "true";            
             };
          };
          multimedia = {
            type = "zfs_fs";
            mountpoint = "/nas/multimedia";            
            options = {
             "com.sun:auto-snapshot" = "true";            
             };
          };
          software = {
            type = "zfs_fs";
            mountpoint = "/nas/software";            
            options = {
             "com.sun:auto-snapshot" = "true";            
             };
          };
        };
      };
    };
  };

  # Set proper permissions for NAS base shares
  system.activationScripts.nas_share_permissions = ''
    ${lib.concatStringsSep "\n" (lib.mapAttrsToList (_: value: 
        "chown nobody:users ${value.mountpoint};
         chmod 0770 ${value.mountpoint};"
      ) 
      (lib.filterAttrs (n: v: v.mountpoint!=null) config.disko.devices.zpool.nas.datasets )
      )
    }
  '';

  # Create homes folders if not exists
  system.activationScripts.nas_share_homes = ''
    ${lib.concatStringsSep "\n" (lib.mapAttrsToList (username: _:
        let
          homePath = "${config.disko.devices.zpool.nas.datasets.homes.mountpoint}/${username}";          
        in
        "mkdir -p ${homePath};
         chown ${username}:${username} ${homePath};
         chmod 0700 ${homePath};"
      ) 
      (lib.filterAttrs (n: v: v.isNormalUser==true) config.users.users)
      )
    }
  '';
}