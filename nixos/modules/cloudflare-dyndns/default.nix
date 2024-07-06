
{ inputs, config, pkgs, nixpkgs, lib, ... }:
{
    sops.secrets."cloudflare_api_token" = {
        sopsFile = ../../../secrets/common/cloudflare-dyndns.yaml;
        restartUnits = [ "cloudflare-dyndns.service" ];
    };

    sops.templates."cloudflare-dyndns-secrets" = {
        content = ''
        CLOUDFLARE_API_TOKEN="${config.sops.placeholder.cloudflare_api_token}"
        '';
    };

    services.cloudflare-dyndns = {
        enable = true;
        ipv4 = true;
        ipv6 = true;
        proxied = false;
        apiTokenFile = config.sops.templates."cloudflare-dyndns-secrets".path;
    };

    environment.systemPackages = with pkgs; [
        screen
    ];

}    