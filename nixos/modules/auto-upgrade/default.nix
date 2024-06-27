{ inputs, config, pkgs,  lib, ... }:
{
  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    dates = "03:00";
    flake = "github:segator/configs";
  };
}