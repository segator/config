{ lib, config, ... }:
let
in
{
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
          nix = {
            size = "50G";
            content = {
              type = "filesystem";
              format = "xfs";
              mountpoint = "/nix";
            };
          };
          persist = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "xfs";
              mountpoint = "/persist";
            };
          };          
        };
      };
    };

    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [
        "size=512M"
        "defaults"
        "mode=755"
      ];
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