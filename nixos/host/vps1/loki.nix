{ inputs, config, pkgs, nixpkgs, lib, ... }:
{
  services.loki = {
    enable = true;
    configFile = ./loki-local-config.yaml;
  };
}