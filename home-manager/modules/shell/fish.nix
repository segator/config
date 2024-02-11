{ config, pkgs, ... }:
{
  programs.fish.enable = true;
  programs.fish.interactiveShellInit = ''
  neofetch
  '';
}