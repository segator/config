{ inputs, config, pkgs, nixpkgs, lib, ... }:
{
  imports = [    
          ./hardware-configuration.nix
          ./disk-config.nix    
          ./persistence.nix       
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

  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID5vRrC3yycYEP9GoKk4nm9iTf9aFMb0pAyKbp5rcEkW segator"
  ];

  services.cloudflare-dyndns.domains = [ "tv.neries.li" ]; 

  time.timeZone = "Europe/Madrid";
  networking.networkmanager.enable = false;
  networking.firewall.enable = true;
}