{ inputs, config, pkgs, nixpkgs, lib, ... }:
let
    alertManagerFqdn = "alert.segator.es";
in
{
    sops.secrets."telegram/bot_token" = {
        sopsFile = ../../../secrets/common/monitoring.yaml;
        mode  = "0444";
    };
    

    sops.secrets."prometheus/auth/htpasswd" = { owner = "nginx"; };
    services.cloudflare-dyndns.domains = [ alertManagerFqdn ]; 
    services.nginx.virtualHosts."${alertManagerFqdn}" = {
      enableACME = true;
      forceSSL = true;
      kTLS = true;     
      locations."/" = {
        proxyPass = "http://${config.services.prometheus.alertmanager.listenAddress}:${toString config.services.prometheus.alertmanager.port}";
      };
    };

    services.prometheus.alertmanager = {
      enable = true;
      #webExternalUrl = "https://${config.networking.fqdn}/alert";
      listenAddress = "127.0.0.1";
      port = 9093;
      extraFlags = [ ''--cluster.listen-address=""'' ];
      configuration = rec {
        route = {
          group_wait = "1s";
          group_interval = "24h";
          repeat_interval = "24h";
          receiver = (builtins.elemAt receivers 0).name;
        };
        receivers = [
          {
            name = "telegram";
            telegram_configs = [
              {
                bot_token_file = config.sops.secrets."telegram/bot_token".path;
                chat_id = -4276135277;
                api_url = "https://api.telegram.org";
                send_resolved = true;
                parse_mode = "HTML";  # Changed to HTML
                message = ''
                  {{ define "alert_details" }}
                  - <b>Alert Name:</b> {{ .Labels.alertname }}  
                    <b>Summary:</b> {{ .Annotations.summary }}                                                    
                    <b>Severity:</b> {{ .Labels.severity }}
                    <b>Description:</b>{{ .Annotations.description }}                    
                    <a href="{{ .GeneratorURL }}">{{ .GeneratorURL }}</a>
                  {{ end }}

                  {{ if gt (len .Alerts.Firing) 0 }}🚨 {{if gt (len .Alerts.Firing) 1 }}Active Alerts{{else}}Active Alert{{end}} ({{ len .Alerts.Firing }})
                  {{ range .Alerts.Firing }}
                  {{ template "alert_details" . }}
                  {{ end }}{{ end }}

                  {{ if gt (len .Alerts.Resolved) 0 }}✅ {{if gt (len .Alerts.Resolved) 1 }}Resolved Alerts{{else}}Resolved Alert{{end}} ({{ len .Alerts.Resolved }})
                  {{ range .Alerts.Resolved }}
                  {{ template "alert_details" . }}
                  {{ end }}{{ end }}
                '';
              }
            ];
          }
        ];
      };
    };

    # Alert Manager prometheus exporter
    services.prometheus.scrapeConfigs = [{
        job_name = "alertmanager";
        scrape_interval = "30s";
        static_configs = [{ 
          targets = [ "${config.services.prometheus.alertmanager.listenAddress}:${toString config.services.prometheus.alertmanager.port}" ]; 
          }];
      }];
}