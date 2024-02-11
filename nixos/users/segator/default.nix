
{ inputs, config, pkgs,  lib, ... }:
{
  users.users.segator = {
   isNormalUser = true;
   description = "Segator";
   shell = pkgs.fish;
   extraGroups = [ "networkmanager" "wheel" "docker" "libvirtd" "qemu-libvirtd"  ];
  };

  # Even defined in home-manager seems we need this at nixos level
  programs.fish.enable = true;
}