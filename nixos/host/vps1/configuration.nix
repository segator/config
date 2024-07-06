{ inputs, config, pkgs, nixpkgs, lib, ... }:
{
  imports = [    
          ./hardware-configuration.nix
          ./disk-config.nix       
          ../../modules/common.nix
          ../../modules/nix-sops
          ../../modules/nix
          ../../modules/sshd
          ../../modules/grafana-agent
          ../../modules/auto-upgrade
          ../../modules/fail2ban  
          ../../modules/cloudflare-dyndns
          ../../modules/grafana-agent
          ../../modules/nginx
          ../../modules/acme
          ../../modules/persistence
          ./prometheus.nix
          ./alertmanager.nix
          #./grafana.nix
          #./loki.nix
  ];

  services.qemuGuest.enable = true;
    boot = {
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
 
  system.stateVersion = "24.05";

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID5vRrC3yycYEP9GoKk4nm9iTf9aFMb0pAyKbp5rcEkW segator"
  ];

  systemd.network.enable = true;
  systemd.network.networks."10-wan" = {
    matchConfig.Name = "enp1s0";
    networkConfig.DHCP = "ipv4";
    address = [
      "2a01:4f8:c0c:6bf5::/64"
    ];
    routes = [
      { routeConfig.Gateway = "fe80::1"; }
    ];
  };

  time.timeZone = "Europe/Madrid";
  networking.networkmanager.enable = false;
  networking.firewall.enable = true;
}