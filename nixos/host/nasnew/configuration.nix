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

          ./users.nix
          ./zfs.nix
          ./nextcloud.nix
          ./samba.nix
          #./nfs.nix
          #./backup.nix
  ];

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
      
  networking.hostName = "nasnew";
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