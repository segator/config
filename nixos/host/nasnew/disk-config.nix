{ lib, ... }:
{
  disko.devices = {
    disk.main = {
      device = "/dev/disk/by-id/ata-Samsung_SSD_860_EVO_500GB_S3Z1NB0K303456L";
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
          zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "zroot";
            };
          };          
        };
      };
    };
    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [
        "size=2G"
        "defaults"
        "mode=755"
      ];
    };
    zpool = {
      zroot = {
        type = "zpool";
        mode = "single";
        rootFsOptions = {
          compression = "zstd";
          "com.sun:auto-snapshot" = "false";
        };
        mountpoint = "none";
        #postCreateHook = "zfs list -t snapshot -H -o name | grep -E '^zroot@blank$' || zfs snapshot zroot@blank";
        # postMountHook = ''
        #     mkdir -p /mnt/persist/system/var/lib/nixos
        #     mkdir -p /mnt/persist/system/etc/nixos
        #     mkdir -p /mnt/persist/system/var/log
        #     mkdir -p /mnt/persist/system/var/lib/systemd/coredump
        #     mkdir -p /persist/services/var/lib/acme
        #     mkdir -p /persist/services/var/lib/nextcloud/data"
        #     mkdir -p /persist/services/var/lib/postgresql"
        #     '';
        datasets = {
          persist = {
            type = "zfs_fs";
            mountpoint = "/persist";
            options = {
             "com.sun:auto-snapshot" = "true"; 
              encryption = "aes-256-gcm";
              keyformat = "passphrase";
            };
          };
          nix = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options = {
             "com.sun:auto-snapshot" = "true"; 
              encryption = "aes-256-gcm";
              keyformat = "passphrase";
            };
          };
          encrypted = {
            type = "zfs_fs";
            options = {
              mountpoint = "none";
              encryption = "aes-256-gcm";
              keyformat = "passphrase";
              keylocation = "file:///tmp/secret.key";
            };
            # use this to read the key during boot
            # postCreateHook = ''
            #   zfs set keylocation="prompt" "zroot/$name";
            # '';
          };
          "encrypted/test" = {
            type = "zfs_fs";
            mountpoint = "/zfs_crypted";
          };
        };
      };
    };
  };
}
