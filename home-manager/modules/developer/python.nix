{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    python3Full
    python313Packages.pip
  ];
}