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
        ./prometheus/alerts/ceph.yaml
        ./prometheus/alerts/zfs.yaml
        ./prometheus/alerts/ups.yaml
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
          targets = [ "${config.networking.hostName}:${toString config.services.prometheus.port}" ]; 
          }];
        relabel_configs = [{
          source_labels= ["__address__"];
          target_label= "instance";
          regex= "([^:]+).*";
          replacement= "\${1}";
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
            }
            #  {
            # source_labels = [ "__param_target" ];
            # target_label = "instance";
            # } 
            {
            target_label = "__address__";
            replacement = "${config.networking.hostName}:${toString config.services.prometheus.exporters.blackbox.port}";
            }            
            {
              source_labels= ["__address__"];
              target_label= "instance";
              regex= "([^:]+).*";
              replacement= "\${1}";
            }];
      }    
      {
        job_name = "blackbox_exporter";
        static_configs = [{
            targets = [ "${config.networking.hostName}:${toString config.services.prometheus.exporters.blackbox.port}" ];
        }];
        relabel_configs = [{
          source_labels= ["__address__"];
          target_label= "instance";
          regex= "([^:]+).*";
          replacement= "\${1}";
        }];  
      }
    ];
    exporters = {
      node = {
        enable = false;
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

