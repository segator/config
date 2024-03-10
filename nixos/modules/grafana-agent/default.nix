{config, pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    grafana-agent
  ];

  #Prometheus
  sops.secrets."grafana/metrics/url" = {
    sopsFile = ../../../secrets/common/monitoring.yaml;
  };
  sops.secrets."grafana/metrics/username" = {
    sopsFile = ../../../secrets/common/monitoring.yaml;
  };
  sops.secrets."grafana/metrics/password" = {
    sopsFile = ../../../secrets/common/monitoring.yaml;
  };

  #Loki
  sops.secrets."grafana/logs/url" = {
    sopsFile = ../../../secrets/common/monitoring.yaml;
  };
  sops.secrets."grafana/logs/username" = {
    sopsFile = ../../../secrets/common/monitoring.yaml;

  };
  sops.secrets."grafana/logs/password" = {
    sopsFile = ../../../secrets/common/monitoring.yaml;
  };


  services.grafana-agent.credentials = {
    LOGS_REMOTE_WRITE_URL = config.sops.secrets."grafana/logs/url".path;
    LOGS_REMOTE_WRITE_USERNAME = config.sops.secrets."grafana/logs/username".path;
    logs_remote_write_password = config.sops.secrets."grafana/logs/password".path;
    METRICS_REMOTE_WRITE_URL = config.sops.secrets."grafana/metrics/url".path;
    METRICS_REMOTE_WRITE_USERNAME = config.sops.secrets."grafana/metrics/username".path;
    metrics_remote_write_password = config.sops.secrets."grafana/metrics/password".path;
  };

  services.grafana-agent.settings = {
    metrics.global = {
      remote_write = [{
        url = "\${METRICS_REMOTE_WRITE_URL}";
        basic_auth.username = "\${METRICS_REMOTE_WRITE_USERNAME}";
        basic_auth.password_file = "\${CREDENTIALS_DIRECTORY}/metrics_remote_write_password";
      }];

      scrape_interval = "60s";
    };

    logs.configs = [{
      name = "default";
      scrape_configs = [
        {
          job_name = "journal";
          journal = {
            max_age = "12h";
            labels.job = "systemd-journal";
          };
          relabel_configs = [
            {
              source_labels = [ "__journal__systemd_unit" ];
              target_label = "systemd_unit";
            }
            {
              source_labels = [ "__journal__hostname" ];
              target_label = "nodename";
            }
            {
              source_labels = [ "__journal_syslog_identifier" ];
              target_label = "syslog_identifier";
            }
          ];
        }
      ];
      positions.filename = "\${STATE_DIRECTORY}/loki_positions.yaml";
      clients = [{
        url = "\${LOGS_REMOTE_WRITE_URL}";
        basic_auth.username = "\${LOGS_REMOTE_WRITE_USERNAME}";
        basic_auth.password_file = "\${CREDENTIALS_DIRECTORY}/logs_remote_write_password";
      }];
    }];
    

  };

  services.grafana-agent.enable = true;
}