{ inputs, config, pkgs,  lib, ... }:
{
    sops.secrets."darthespinete" = {
        sopsFile = ../../../secrets/common/wifi.yaml;
        owner = "root";
        group = "root";
        mode = "0600";
        path = "/etc/NetworkManager/system-connections/DarthEspinete.nmconnection";
    };
    sops.secrets."airway" = {
        sopsFile = ../../../secrets/common/wifi.yaml;
        owner = "root";
        group = "root";
        mode = "0600";
        path = "/etc/NetworkManager/system-connections/Airway.nmconnection";
    };
}
