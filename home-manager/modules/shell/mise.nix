{ config, pkgs, ... }:
{
    programs.mise = {
        enable = true;
        enableBashIntegration = true;
    };
}