{ config, pkgs, ... }:

{
  imports = [
    ../../../modules/spotify
    ../../../modules/developer
    ../../../modules/devops
    ../../../modules/work
    ../../../modules/office    
  ];
}
