{ config, pkgs, ... }:
{
  programs.lsd.enable = true;
  programs.lsd.enableAliases= true;
}