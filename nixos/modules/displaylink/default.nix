{ inputs, config, pkgs,  lib, ... }:
{
    #nix-prefetch-url --name displaylink-600.zip https://www.synaptics.com/sites/default/files/exe_files/2024-05/DisplayLink%20USB%20Graphics%20Software%20for%20Ubuntu6.0-EXE.zip
    
    # We get updated code from main evdi repo as they didn't released a version with the needed to fix
    # to support kernel 6.6+ with displayport
    nixpkgs.overlays = [
      (import ./overlay-patch.nix)
    ];
    nixpkgs.config.allowBroken = true;
    
    services.xserver.videoDrivers = [ "modesetting" "displaylink" ];
    boot.extraModulePackages = with config.boot.kernelPackages; [
        evdi
  ];
}