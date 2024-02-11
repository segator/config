{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
      lazydocker
      kind
      kubectl
  ];
}