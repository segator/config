{ lib, ... }:
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
            # options = {
            #   mountpoint = "legacy";
            # };
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
    };
  };
}
