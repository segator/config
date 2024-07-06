{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
  ];
  
  networking.useDHCP = true;

  boot.initrd.availableKernelModules = [ "r8169" "ahci" "xhci_pci" "virtio_pci" "virtio_net" "sr_mod" "virtio_blk" ];
}