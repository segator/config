{ config, pkgs, ... }:

{
  imports = [
    ../../modules/shell
    ../../modules/sops
  ];
  
  home.username = "segator";
  home.homeDirectory = "/home/segator";

  home.stateVersion = "23.05"; 

  programs.home-manager.enable = true;
}
