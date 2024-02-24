{ inputs, config, pkgs,  lib, ... }:
{
    services.logind.lidSwitchExternalPower = "ignore";
    services.logind.lidSwitchDocked = "ignore";
    services.logind.lidSwitch = "suspend";
}