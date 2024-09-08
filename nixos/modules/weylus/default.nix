{ inputs, config, pkgs,  lib, ... }:
{
    programs.weylus = {
        enable = true;
        openFirewall = true;
        users = lib.attrNames (lib.filterAttrs (_: user: user.isNormalUser) config.users.users);
    };
}