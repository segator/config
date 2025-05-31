{ inputs, config, pkgs, nixpkgs, lib, ... }:
{
  imports = [    
          ./hardware-configuration.nix
          ./disk-config.nix    
          #../../modules/zfs/sse4-support.nix
          ../../modules/common.nix
          ../../modules/nix-sops
          ../../modules/nix
          ../../modules/sshd
          #../../modules/grafana-agent
          ../../modules/auto-upgrade
          ../../modules/fail2ban
          ../../modules/cloudflare-dyndns
          ../../modules/nginx
          ../../modules/acme
          ../../modules/persistence
          ./nas_options.nix
          ./users.nix
          #./zfs.nix

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
        backup = true; 
      };

      # crbmc = {
      #   path = "/nas/crbmc";
      #   backup = true;
      #   groups = [ "carles" ];        
      # };

      software = {
        path = "/nas/software";
        groups = [ "isaacaina" ];
        backup = true;
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
  
  hardware.graphics.package = (pkgs.mesa.override {
    enableGalliumNine = false;
    galliumDrivers = [ "swrast" "virgl" ];
  }).drivers;

  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;
  boot = {
    initrd = {
      secrets = { 
        "/etc/secrets/initrd/ssh_host_ed25519_key" = lib.mkForce /persist/system/initrd/ssh_host_ed25519_key;
      };
      # clevis = {
      #   enable = true;
      #   useTang = true;
      #   devices."persist".secretFile = ./persist.jwe;
      # };
      # systemd = {
      #   enable = true;
      #   users.root.shell = "/bin/cryptsetup-askpass";
      #   network = {
      #     wait-online.enable = true;
      #     wait-online.anyInterface = true;
      #     wait-online.timeout = 1440; #1d      
      #   };
      # };
      # network = {
      #   enable = true;
       
      #   ssh = {
      #     enable = true;             
      #     port = 2222; 
      #     hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];              
      #     authorizedKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID5vRrC3yycYEP9GoKk4nm9iTf9aFMb0pAyKbp5rcEkW segator" ];
      #   };
      # };
    }; # "RDkLJx9u*cemjUr"

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