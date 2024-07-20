{ inputs, config, pkgs, nixpkgs, lib, ... }:
let
    proxyliveFqdn = "cdn.neries.li";
    proxyliveBackendHost = "100.101.241.49:8080";
in
{
   services.cloudflare-dyndns.domains = [ proxyliveFqdn ]; 
    services.nginx.virtualHosts."${proxyliveFqdn}" = {
      enableACME = true;
      forceSSL = true;
      kTLS = true;     
      locations."/" = {
        proxyPass = "http://${proxyliveBackendHost}";
      };
    };
    services.prometheus.scrapeConfigs = [
      {
        job_name = "proxylive";
        scrape_interval = "30s";
        metrics_path= "/actuator/prometheus";
        static_configs = [{ 
          targets = [ "${proxyliveBackendHost}" ]; 
          }];
        relabel_configs = [{
          source_labels= ["__address__"];
          target_label= "instance";
          regex= "([^:]+).*";
          replacement= "\${1}";
        }];
      }
    ];
    # sops.secrets."proxylive/m3u8url" = { 
    #     restartUnits = [ "docker-proxylive.service" ]; 
    # };
    # sops.templates."application.yml" = {
    #     owner = "docker";
    #     group = "docker";
    #     content = ''        
    #         spring.jackson.serialization.INDENT_OUTPUT: true
    #         management:
    #             server:
    #                 port: 8080
    #             endpoints:
    #                 prometheus:
    #                     enabled: true
    #                 metrics:
    #                     enabled: true
    #                 web:
    #                     exposure:
    #                         include: "*"
    #             metrics:
    #                 export:
    #                     prometheus:
    #                         enabled: true
    #         geoIP:
    #             enabled: false
    #             url: https://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz
    #         source:
    #             m3u8URL: "${config.sops.placeholder."proxylive/m3u8url"}"
    #             epg:
    #                 refresh: 600
    #             channels:
    #                 type: m3u8
    #                 refresh: 60
    #             reconnectTimeout: 30


    #         authentication:
    #             expireInHours: 48
    # '';
    # };
    
    # virtualisation.oci-containers = {
    #     backend = "docker";
    #     containers = {
    #         proxylive = {
    #             image = "segator/proxylive:master"; # The Docker image you want to use
    #             autoStart = true;
    #             volumes = [ "${config.sops.templates."application.yml".path}:/app/application.yml:ro" ];
    #             ports = [ "8080:8080" ];
    #         };
        
    #     };
    # };
    # networking.firewall.allowedTCPPorts = [
    #     8080
    # ];
}