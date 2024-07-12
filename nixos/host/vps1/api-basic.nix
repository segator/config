{ inputs, config, pkgs, nixpkgs, lib, ... }:
let
    apiFqdn = "api.segator.es";
in 
{
  sops.secrets."prometheus/auth/htpasswd" = { owner = "nginx"; };
  services.cloudflare-dyndns.domains = [ apiFqdn ]; 
  services.nginx.virtualHosts."${apiFqdn}" = {
      enableACME = true;
      forceSSL = true;
      kTLS = true;
      locations =  {
        "/prom" = {
          proxyPass = "http://${config.services.prometheus.listenAddress}:${toString config.services.prometheus.port}";
          extraConfig = ''
            rewrite /prom/(.*)$ /$1 break;
          '';
          
          basicAuthFile = config.sops.secrets."prometheus/auth/htpasswd".path; 
        };
      };      
    };
}