{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
  ];
  
  networking.useDHCP = lib.mkDefault true;

  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "virtio_net" "sr_mod" "virtio_blk" ];
  boot.initrd.kernelModules = [ "virtio_gpu" ];
  boot.kernelParams = [ "ip=dhcp" ];
  #boot.kernelModules = [ ];
  #boot.extraModulePackages = [ ];
}