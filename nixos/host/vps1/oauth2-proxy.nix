{ inputs, config, pkgs, nixpkgs, lib, ... }:
let
    oauth2proxyFqdn = "auth.segator.es";
    oauth2LocalAddr = "http://127.0.0.1:4180";
    oauth2LocalMetricPort = "4185";
    oauth2LocalMetricAddr = "127.0.0.1:${oauth2LocalMetricPort}";
in
{
    sops.secrets."oauth2-proxy/secrets" = { owner = "oauth2-proxy"; };
    sops.secrets."oauth2-proxy/allowed_emails" = { owner = "oauth2-proxy"; };
    services.cloudflare-dyndns.domains = [ oauth2proxyFqdn ]; 
    services.nginx.virtualHosts."${oauth2proxyFqdn}" = {
      enableACME = true;
      forceSSL = true;      
      kTLS = true;
      locations."/" = {
        proxyPass = oauth2LocalAddr;
      };
    };
    services.oauth2-proxy = {
        enable = true;
        provider = "google";
        keyFile = config.sops.secrets."oauth2-proxy/secrets".path;
        passBasicAuth = true;
        #upstreams = [ "https://prom.segator.es" "https://alert.segator.es" ];
        httpAddress = oauth2LocalAddr;
        reverseProxy = true;
        scope = "openid profile email";
        nginx.domain = oauth2proxyFqdn;
        cookie = {
            domain = ".segator.es";
            expire = "24h";
        };
        setXauthrequest = true;
        nginx.virtualHosts = {
            "prom.segator.es" = {};
            "alert.segator.es" = {};
        };
        extraConfig = {
            skip-provider-button = true;
            whitelist-domain = "*.segator.es";
            cookie-samesite = "lax";
            metrics-address = "http://${oauth2LocalMetricAddr}";
            authenticated-emails-file = config.sops.secrets."oauth2-proxy/allowed_emails".path;    
        };

    };
    # oauth2-proxy prometheus exporter
    services.prometheus.scrapeConfigs = [{
        job_name = "oauth2-proxy";
        scrape_interval = "30s";
        static_configs = [{ 
          targets = [ "${config.networking.hostName}:${oauth2LocalMetricPort}" ]; 
          }];
        relabel_configs = [{
          source_labels= ["__address__"];
          target_label= "instance";
          regex= "([^:]+).*";
          replacement= "\${1}";
        }];  
      }];
   
}