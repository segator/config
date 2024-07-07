{ inputs, config, pkgs, nixpkgs, lib, ... }:
let
    prometheusFqdn = "prom.segator.es";
in
{ 
  services.prometheus = {
    enable = true;
    retentionTime = "365d";
    listenAddress = "127.0.0.1";
    webExternalUrl = "https://${prometheusFqdn}";
    # rules ;
    ruleFiles = [ 
        ./prometheus/alerts/prometheus.yaml
        ./prometheus/alerts/node-exporter.yaml
        ./prometheus/alerts/blackbox.yaml
        ];
    extraFlags = [ "--web.enable-remote-write-receiver" ];
    alertmanagers = [{
      scheme = "http";
      static_configs = [{
        targets =
          [ "${config.services.prometheus.alertmanager.listenAddress}:${toString config.services.prometheus.alertmanager.port}" ];
      }];
    }];
    scrapeConfigs = [
      {
        job_name = "prometheus";
        scrape_interval = "30s";
        static_configs = [{ 
          targets = [ "${config.services.prometheus.listenAddress}:${toString config.services.prometheus.port}" ]; 
          }];
      }
     
      {
        job_name = "blackbox_http_probe";
        metrics_path= "/probe";
        params = {
            module = [ "http_2xx" ];
        };
        static_configs = [{
            targets = [ "https://cloud.segator.es" ];
        }];
        relabel_configs = [ 
            {
            source_labels = [ "__address__" ];
            target_label = "__param_target";
            } {
            source_labels = [ "__param_target" ];
            target_label = "instance";
            } {
            target_label = "__address__";
            replacement = "localhost:${toString config.services.prometheus.exporters.blackbox.port}";
            } ];
      }    
      {
        job_name = "blackbox_exporter";
        static_configs = [{
            targets = [ "localhost:${toString config.services.prometheus.exporters.blackbox.port}" ];
        }];
      }
    ];
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" "pressure" ];
      };
    };
  };

  services.grafana.provision.datasources.settings = {
    apiVersion = 1;
    datasources = [{
      name = "Prometheus";
      type = "prometheus";
      url = "http://127.0.0.1:9090";
      orgId = 1;
    }];
    deleteDatasources = [{
      name = "Prometheus";
      orgId = 1;
    }];
  };
  sops.secrets."prometheus/auth/htpasswd" = { owner = "nginx"; };
  services.cloudflare-dyndns.domains = [ prometheusFqdn ]; 
  services.nginx.virtualHosts."${prometheusFqdn}" = {
      enableACME = true;
      forceSSL = true;
      kTLS = true;
      locations =  {
        "/api/" = {
          proxyPass = "http://${config.services.prometheus.listenAddress}:${toString config.services.prometheus.port}";
          extraConfig = "auth_request off;";
          basicAuthFile = config.sops.secrets."prometheus/auth/htpasswd".path; 
        };
        "/" = {
          proxyPass = "http://${config.services.prometheus.listenAddress}:${toString config.services.prometheus.port}";
        };
      };      
    };
    # https://github.com/prometheus/blackbox_exporter/blob/master/CONFIGURATION.md
    services.prometheus.exporters.blackbox =    
    {
      enable = true;
      listenAddress = "127.0.0.1";
      port = 9115;
      configFile = ./prometheus/blackbox.yml;
    };
}

