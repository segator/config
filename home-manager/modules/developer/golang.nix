{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    jetbrains.goland
    go_1_20
    gcc  
  ];
}