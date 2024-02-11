{ config, pkgs, ... }:
{
  programs.starship.enable = true;
  programs.starship.enableFishIntegration = true;
  programs.starship.enableBashIntegration = true;
  programs.starship.settings = {

  };
}