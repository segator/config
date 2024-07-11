{ inputs, config, pkgs, nixpkgs, lib, ... }:
let
zfsUnattendedUnlockPkg = (pkgs.writeShellScriptBin "unattended-zfs-unlock" ''
          for pool_name in "$@"; do
            while true; do
              echo "running clevis to unlock $pool_name"
              #zpool status $pool_name || zpool import -f $pool_name
              zpool import -a
              zfs get -H clevis:jwe -s local "$pool_name" | awk '{print $3}' | clevis decrypt | zfs load-key "$pool_name"
              if [[ $? -eq 0 ]]; then
                echo "ZFS decryption and key loading succeeded for pool: $pool_name."
                break
              else
                echo "ZFS decryption and key loading failed for pool: $pool_name. Retrying..."
                sleep 1
              fi
            done
          done
        '');
  zfsUnlockPkg = (pkgs.writeShellScriptBin "zfs-unlock" ''
    zpool import -a
    zfs load-key zroot
    #zfs load-key nas
    ${pkgs.killall}/bin/killall zfs
  '');
in
{
  imports = [    
          ./hardware-configuration.nix
          ./disk-config.nix    
          ../../modules/zfs/sse4-support.nix
          ../../modules/common.nix
          ../../modules/nix-sops
          ../../modules/nix
          ../../modules/sshd
          ../../modules/grafana-agent
          ../../modules/auto-upgrade
          ../../modules/fail2ban
          ../../modules/cloudflare-dyndns
          ../../modules/nginx
          ../../modules/acme
          ../../modules/persistence
          ./nas_options.nix
          ./users.nix
          ./zfs.nix

          ./postgresql.nix
          ./nextcloud.nix
          ./samba.nix
          ./mail_telegram.nix
          ./smartd.nix
          #./nfs.nix
          ./borgbackup.nix
          ./kopiabackup.nix          
  ];

  nas = {
    users = {
      daga12g = { 
        uid = 1000; 
        passwordFile = config.sops.secrets."daga12g_password".path;
        };
      segator = { 
        uid = 1001; 
        passwordFile = config.sops.secrets."segator_password".path;
      };
      carles = {
         uid = 1002; 
         passwordFile = config.sops.secrets."carles_password".path;
      };
      charo = {
        uid = 1003;
        passwordFile = config.sops.secrets."charo_password".path;
      };
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
          "charo"
        ];
      };
    };
    shares = {
      homes = {
          path = "/nas/homes";
          groups = [ "nasusers" ];
          backup = true;
          isHome = true;  
      };
      isaacaina = {
        path = "/nas/isaacaina";      
        backup = true;
        groups = [ "isaacaina" ];        
      };

      multimedia = {
        path = "/nas/multimedia";
        groups = [ "isaacaina" ];     
      };

      # crbmc = {
      #   path = "/nas/crbmc";
      #   backup = true;
      #   groups = [ "carles" ];        
      # };

      software = {
        path = "/nas/software";
        groups = [ "isaacaina" ];
      };     
    }; 
  };

  sops.secrets = {
    "ceph_nas" = { };
  } //
  builtins.listToAttrs (
    builtins.map (key: 
      {name = "${key}_password"; value = {};}) (builtins.attrNames config.nas.users
    )
  );

  #fileSystems."/nas".neededForBoot = true;
  
  hardware.graphics.package = (pkgs.mesa.override {
    enableGalliumNine = false;
    galliumDrivers = [ "swrast" "virgl" ];
  }).drivers;

  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;
  boot = {
      initrd.secrets = { 
        "/etc/secrets/initrd/ssh_host_ed25519_key" = lib.mkForce /persist/system/initrd/ssh_host_ed25519_key;
      };
      initrd.clevis.enable = true;
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
            cat ${zfsUnattendedUnlockPkg}/bin/unattended-zfs-unlock
            ${zfsUnlockPkg}/bin/zfs-unlock
          else
            echo "zfs not running -- maybe the pool is taking some time to load for some unforseen reason."
          fi
          EOF

          ${zfsUnattendedUnlockPkg}/bin/unattended-zfs-unlock zroot  & # nas
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
      
  environment.systemPackages = with pkgs; [ ceph fio];
  # To generate the secret
  # ceph fs authorize <pool-name> client.<client-name> / rw

  fileSystems."/nas" = { 
    device = "192.168.0.254,192.168.0.252,192.168.0.250,192.168.0.249:/";
    fsType = "ceph";
    options = ["name=nas" "secretfile=${ config.sops.secrets."ceph_nas".path}" "mds_namespace=nas" ];
  };

  services.resilio = {
    enable = true;
    enableWebUI = true;
    useUpnp = false;
    httpListenAddr = "0.0.0.0";
    listeningPort = 53210;
    httpListenPort = 9000;
    deviceName = config.networking.hostName;    
  };
  networking.firewall.allowedTCPPorts = [ config.services.resilio.httpListenPort config.services.resilio.listeningPort ];
  networking.firewall.allowedUDPPorts = [ config.services.resilio.listeningPort ];

  networking.hostId = "4e98920d";
  system.stateVersion = "24.05";

  services.openssh.enable = true;
  #users.users.root.password = "nixos";
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID5vRrC3yycYEP9GoKk4nm9iTf9aFMb0pAyKbp5rcEkW segator"
  ];

  time.timeZone = "Europe/Madrid";
  networking.networkmanager.enable = false;
  networking.firewall.enable = true;
}