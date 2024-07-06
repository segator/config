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
      basicAuthFile =  config.sops.secrets."prometheus/auth/htpasswd".path;
      locations."/" = {
        proxyPass = "http://${config.services.prometheus.alertmanager.listenAddress}:${toString config.services.prometheus.alertmanager.port}";
        extraConfig = "proxy_pass_header Authorization;";
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
          #group_wait = "30s";
          #group_interval = "5m";
          #repeat_interval = "3h";
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
                parse_mode = "HTML";
                message = ''
                    {{ define "alert_details" }}
                    - **Alert Name:** {{ .Labels.alertname }}
                    **Summary:** {{ .Annotations.summary }}
                    **Description:** {{ .Annotations.description }}
                    **URL:** {{ .GeneratorURL }}
                    {{ end }}

                    {{ if gt (len .Alerts.Firing) 0 }}🚨 {{if gt (len .Alerts.Firing) 1 }}Active Alerts{{else}}Active Alert{{end}} ({{ len .Alerts.Firing }})
                    {{ range .Alerts.Firing }}
                    {{ template "alert_details" . }}
                    {{ end }}{{ end }}

                    {{ if gt (len .Alerts.Resolved) 0 }}✅ {{if gt (len .Alerts.Resolved) 1 }}Resolved Alerts{{else}}Resolved Alert{{end}} ({{ len .Alerts.Resolved }})
                    {{ range .Alerts.Resolved }}
                    {{ template "alert_details" . }}
                    {{ end }}{{ end }}'';
              }
            ];
          }
        ];
      };
    };
}