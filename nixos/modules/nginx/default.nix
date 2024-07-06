{ self, config, lib, pkgs, ... }:
{
    my.monitoring.logs = [
        {
        name = "nginx";
        path = "/var/log/nginx/*.log";
        }
    ];

    services.nginx = {
        enable = true;
        recommendedGzipSettings = true;
        recommendedOptimisation = true;
        recommendedTlsSettings = true;
    };
}