{ inputs, config, pkgs, nixpkgs, lib, ... }:
{
  fileSystems."/persist".neededForBoot = true;  
  environment.persistence."/persist/system" = {
    hideMounts = false;
    directories = [
      "/etc/nixos"
      "/var/log"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
    ];
    files = [
      "/etc/machine-id"
      { file = "/etc/ssh/id_rsa"; parentDirectory = { mode = "u=rwx,g=,o="; }; }
      { file = "/etc/ssh/ssh_host_ed25519_key"; parentDirectory = { mode = "u=rwx,g=,o="; }; }
    ];
  };

  environment.persistence."/persist/services" = {
    hideMounts = false;
    directories = 
    (lib.optionals ((lib.attrNames config.security.acme.certs)!=[]) ["/var/lib/acme"])
    ++ 
    (lib.optionals config.services.nextcloud.enable [{ directory = config.services.nextcloud.datadir; user = "nextcloud"; group = "nextcloud"; mode = "u=rwx,g=rwx,o="; }])
    ++
    (lib.optionals config.services.postgresql.enable [{ directory = config.services.postgresql.dataDir; user = "postgres"; group = "postgres"; mode = "u=rwx,g=rwx,o="; }])
    ++
    (lib.optionals config.services.postgresqlBackup.enable [{ directory = config.services.postgresqlBackup.location; user = "postgres"; group = "postgres"; mode = "u=rwx,g=rwx,o="; }])
    ++
    (lib.optionals config.services.grafana.enable [{ directory = config.services.grafana.dataDir; user = "grafana"; group = "grafana"; }])
    ++
    (lib.optionals config.services.prometheus.enable [{ directory = "/var/lib/prometheus2"; user = "prometheus"; group = "prometheus"; }])
    ++
    (lib.optionals config.services.samba.enable ["/var/lib/samba"])
    ++
    (lib.optionals config.virtualisation.docker.enable [config.virtualisation.docker.daemon.settings."data-root"])
    ++
    (lib.optionals config.services.rabbitmq.enable [config.services.rabbitmq.dataDir])
    ++
    (lib.optionals config.services.onlyoffice.enable ["/var/lib/onlyoffice" ])
    ++
    (lib.optionals config.services.resilio.enable [ config.services.resilio.storagePath])
    ++
    (map (borgConfig: borgConfig.borg_base_directory)  (builtins.attrValues config.services.borgmatic.configurations))
    ++
    (map (borgConfig: borgConfig.borgmatic_source_directory)  (builtins.attrValues config.services.borgmatic.configurations))
    ++ [ "/var/kopia"];   
  };
}