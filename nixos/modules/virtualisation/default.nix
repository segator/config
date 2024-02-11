{ inputs, config, pkgs,  lib, ... }:
{
   virtualisation.libvirtd.enable = true;
   virtualisation.multipass.enable = true;
   virtualisation = {
    docker.enable = true;
   };
}