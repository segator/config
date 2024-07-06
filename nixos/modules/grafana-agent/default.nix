{config, lib, pkgs, ...}:
let
    cfg = config.my.monitoring;    
in
{
    options.my.monitoring = {
        logs = lib.mkOption {
          type = with lib.types; listOf (submodule {
            options = {
              path = lib.mkOption {
                  type = str;                            
              };
              name = lib.mkOption {
                  type = str;
                  default = false;
              };
            };
          });
          default = [];
        };
        prom-exporters = lib.mkOption {
          type = with lib.types; listOf (submodule {
            options = {
              name = lib.mkOption {
                  type = str;                            
              };
              target = lib.mkOption {
                  type = str;
              };
              scheme = lib.mkOption {
                  type = str;
                  default = "http";
              };
            };
          });
          default = [];
        };
    };
    config = {
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
          metrics= {
            global = {
              remote_write = [{
                url = "\${METRICS_REMOTE_WRITE_URL}";
                basic_auth.username = "\${METRICS_REMOTE_WRITE_USERNAME}";
                basic_auth.password_file = "\${CREDENTIALS_DIRECTORY}/metrics_remote_write_password";
              }];

              scrape_interval = "60s";
            };
            configs = [{
              name = "prometheus_scrape_configs";
              scrape_configs = (map (promJob: {
                job_name = promJob.name;
                inherit (promJob) scheme;
                static_configs = [{
                  targets = [promJob.target];
                  labels = {
                    job = promJob.name;
                    host = config.networking.hostName;
                  };
                }];
              }) config.my.monitoring.prom-exporters); 
            }];
          };
          logs.configs = [
            {
            name = "default";
            scrape_configs = 
              (
                map (logJob: 
                  {
                    job_name = logJob.name;
                    static_configs = [{
                      targets = [ "localhost" ];
                      labels = {
                        job = logJob.name;
                        host = config.networking.hostName;
                        "__path__" = logJob.path;
                      };
                    }];                      
                  }
                )
              config.my.monitoring.logs
              )
              ++
              [              
              {
                job_name = "systemd-journal";
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
                    target_label = "hostname";
                  }
                  {
                    source_labels = [ "__journal_syslog_identifier" ];
                    target_label = "syslog_identifier";
                  }
                  {
                    source_labels = [ "__journal__pid" ];
                    target_label = "pid";
                  }
                  {
                    source_labels = [ "__journal__uid" ];
                    target_label = "uid";
                  }
                  {
                    source_labels = [ "__journal__transport" ];
                    target_label = "transport";
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
        systemd.services.grafana-agent = {
          serviceConfig = {
            DynamicUser = lib.mkForce false;
            User = "root";
          };
        }; 
    };
}
