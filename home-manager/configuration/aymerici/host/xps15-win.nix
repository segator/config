{ lib, config, pkgs, inputs, ... }:
{
  imports = [
    #../../../modules/spotify
    #../../../modules/developer    
    ../../../modules/devops
    ../../../modules/roche
    ../../../modules/developer/github.nix
    #../../../modules/work
    #../../../modules/office
    #../../../modules/gnome
  ];



  
}
