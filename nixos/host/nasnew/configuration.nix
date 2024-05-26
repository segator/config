{ inputs, config, pkgs, nixpkgs, lib, ... }:
{
  imports = [    
          ./hardware-configuration.nix
          ./disk-config.nix    
          ./persistence.nix       
          ../../modules/zfs/sse4-support.nix
          ../../modules/common.nix
          ../../modules/nix-sops
          ../../modules/nix
          ../../modules/sshd    

          ../../modules/grafana-agent
          #../../users/segator
          #../../users/daga12g
          #../../users/carles
          ./nas_options.nix
          ./users.nix
          ./zfs.nix
          ./nextcloud.nix
          ./samba.nix
          ./mail_telegram.nix
          ./smartd.nix
          #./nfs.nix
          #./backup.nix
  ];

  nas = {
    users = {
      daga12g = { uid = 1000; passwordFile = config.sops.secrets."daga12g_password".path;};
      segator = { uid = 1001; passwordFile = config.sops.secrets."segator_password".path;};
      carles = { uid = 1002; passwordFile = config.sops.secrets."carles_password".path;};
    };
    groups = {
      isaacaina = {
        gid = 1100;
        members = [
          "daga12g"
          "segator"
        ];
      };
      aymerich = {
        gid = 1101;
        members = [
          "daga12g"
          "segator"
          "carles"
        ];
      };
    };
    shares = {
      isaacaina = {
        path = "/nas/isaacaina";      
        groups = [ "isaacaina" ];        
      };

      multimedia = {
        path = "/nas/multimedia";
        groups = [ "aymerich" ];     
      };

      crbmc = {
        path = "/nas/crbmc";
        groups = [ "aymerich" ];        
      };

      software = {
        path = "/nas/software";
        groups = [ "aymerich" ];
      };     
    }; 
  };

  sops.secrets = builtins.listToAttrs (
    builtins.map (key: 
      {name = "${key}_password"; value = {};}) (builtins.attrNames config.nas.users
    )
  );

  boot = {
      initrd.secrets = { 
        "/etc/secrets/initrd/ssh_host_ed25519_key" = lib.mkForce /persist/system/initrd/ssh_host_ed25519_key;
      };
      initrd.network = {
        enable = true;
        ssh = {
          enable = true;             
          port = 2222; 
          hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];              
          authorizedKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID5vRrC3yycYEP9GoKk4nm9iTf9aFMb0pAyKbp5rcEkW segator" ];
        };
        postCommands = ''
          cat <<EOF > /root/.profile
          if pgrep -x "zfs" > /dev/null
          then
            zpool import -a
            zfs load-key zroot
            zfs load-key nas
            killall zfs
          else
            echo "zfs not running -- maybe the pool is taking some time to load for some unforseen reason."
          fi
          EOF
        '';
      };
    loader.grub = {
        enable = true;
        copyKernels = true;
        # no need to set devices, disko will add all devices that have a EF02 partition to the list already
        # devices = [ ];
        efiSupport = true;
        efiInstallAsRemovable = true;
    };
  };
      
  networking.hostId = "4e98920d";
  system.stateVersion = "23.05";

  services.openssh.enable = true;

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID5vRrC3yycYEP9GoKk4nm9iTf9aFMb0pAyKbp5rcEkW segator"
  ];

  time.timeZone = "Europe/Madrid";
  networking.networkmanager.enable = false;
  networking.firewall.enable = true;
  # Auto update
  system.autoUpgrade.enable = true;
}