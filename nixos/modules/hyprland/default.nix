{ inputs, config, pkgs,  lib, ... }:
{
programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
  };
}