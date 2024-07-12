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

    # disk.sdb = {
    #   device = "/dev/sdb"; # /dev/disk/by-id/ata-Samsung_SSD_860_EVO_500GB_S3Z1NB0K303456L"
    #   type = "disk";
    #   content = {
    #     type = "gpt";
    #     partitions = {
    #       nas = {
    #         size = "100%";
    #         content = {
    #           type = "zfs";
    #           pool = "nas";
    #         };
    #       };          
    #     };
    #   };
    # };
    # disk.sdc = {
    #   device = "/dev/sdc"; # /dev/disk/by-id/ata-Samsung_SSD_860_EVO_500GB_S3Z1NB0K303456L"
    #   type = "disk";
    #   content = {
    #     type = "gpt";
    #     partitions = {
    #       nas = {
    #         size = "100%";
    #         content = {
    #           type = "zfs";
    #           pool = "nas";
    #         };
    #       };          
    #     };
    #   };
    # };
    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [
        "size=512M"
        "defaults"
        "mode=755"
      ];
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
          encryption = "aes-256-gcm";
          keyformat = "passphrase";
          keylocation = "file:///tmp/disk.key";
          dedup = "on";   
        };

        postCreateHook = ''
          # after disko creates the encrypted volume we switch to prompt for next boots
          zfs set keylocation="prompt" "zroot";  
          zfs set clevis:jwe=$(cat /tmp/disk.key.jwe) zroot
        '';
        datasets = {
          # root = {
          #   type = "zfs_fs";
          #   mountpoint = "/";
          #   postCreateHook = "zfs snapshot zroot/root@empty";
          # };
          persist = {
            type = "zfs_fs";
            mountpoint = "/persist";
           

          };
          nix = {
            type = "zfs_fs";
            mountpoint = "/nix";
          };
        };
      };


      # nas = {
      #   type = "zpool";
      #   mode = "mirror";
      #   rootFsOptions = {
      #     mountpoint = "none";
      #     acltype = "posixacl";
      #     xattr = "sa";
      #     atime = "off";
      #     compression = "zstd";

      #     encryption = "aes-256-gcm";
      #     keyformat = "passphrase";
      #     keylocation = "file:///tmp/disk.key";
      #     dedup = "off";
      #     # Speed tunning # we only store some cold big files
      #     logbias = "throughput";
      #     recordsize = "1M";
      #     sync = "disabled"; 
      #     ####
      #   };

      #   postCreateHook = ''
      #     # after disko creates the encrypted volume we switch to prompt for next boots
      #     zfs set keylocation="prompt" "nas";
      #     zfs set clevis:jwe=$(cat /tmp/disk.key.jwe) nas
          
      #   '';

      #   datasets = {
      #     root = {
      #       type = "zfs_fs";
      #       mountpoint = "/nas_old";
      #     };
      #   } // lib.mapAttrs (name: value: {
      #       type = "zfs_fs";
      #       mountpoint = "/nas_old/${name}"; #old way--> value.path
      #   }) config.nas.shares;        
      # };
    };
  };

  #Set proper permissions for NAS base shares
  system.activationScripts.nas_share_permissions = { 
    deps = [ "users" "groups"];
    text=''
    ${lib.concatStringsSep "\n" (lib.mapAttrsToList (_: value: 
        ''
        chown nobody:nasservices "${value.path}";
        chmod 0770 "${value.path}";
        chmod g+s "${value.path}";
        ''
      ) 
      (lib.filterAttrs (n: v: v.path!=null) config.nas.shares )
      )
    }
  '';
  };

  # Create homes folders if not exists
  system.activationScripts.nas_share_homes = 
  {
    deps = [ "nas_share_permissions" ];
    text = ''
    ${lib.concatStringsSep "\n" (lib.mapAttrsToList (username: _:
        let
          homePath = "${config.nas.shares.homes.path}/${username}";          
        in
        ''
        mkdir -p "${homePath}";
        chown ${username}:nasservices "${homePath}";
        chmod 0770 "${homePath}";
        ''
      ) 
      config.nas.users
      )
    }
  '';
  };
}