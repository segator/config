{ inputs, config, pkgs,  lib, ... }:
{
  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
    dates = "03:00";
    flake = "github:segator/config";
  };
}