{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
  ];
  
  networking.useDHCP = lib.mkDefault true;

  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "sr_mod" "virtio_blk" ];
  boot.initrd.kernelModules = [ "virtio_gpu" ];
  #boot.kernelParams = [ "console=tty" ];
  #boot.kernelModules = [ ];
  #boot.extraModulePackages = [ ];
}