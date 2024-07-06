{ lib, config, ... }:
let
in
{
  # boot.initrd.postDeviceCommands = lib.mkAfter ''
  #   zfs rollback -r zroot/root@empty
  # '';

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
          root = {
            size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ]; # Override existing partition
                # Subvolumes must set a mountpoint in order to be mounted,
                # unless their parent is mounted
                subvolumes = {
                  "/nix" = {
                    mountOptions = [ "compress=zstd" "noatime" ];
                    mountpoint = "/nix";
                  };
                  # This subvolume will be created but not mounted
                  "/persist" = {  
                    mountOptions = [ "compress=zstd" "noatime" ];
                    mountpoint = "/persist"; };
                  # Subvolume for the swapfile
                  "/swap" = {
                    mountpoint = "/.swapvol";
                    swap = {
                      swapfile.size = "8G";                     
                    };
                  };
                };
          };          
        };
      };
    };
    };

    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [
        "size=200M"
        "defaults"
        "mode=755"
      ];
    };
  };
}