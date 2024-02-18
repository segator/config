{ config, pkgs, krew2nix, ... }:

{
  imports = [
    ../../../modules/developer
    ../../../modules/devops
  ];
}
