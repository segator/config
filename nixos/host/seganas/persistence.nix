
{ inputs, config, pkgs, nixpkgs, lib, ... }:
{
  fileSystems."/persist".neededForBoot = true;
  fileSystems."/nas".neededForBoot = true;
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
    (lib.optionals config.services.nextcloud.enable [config.services.nextcloud.datadir])
    ++
    (lib.optionals config.services.postgresql.enable [config.services.postgresql.dataDir])
    ++
    (lib.optionals config.services.postgresqlBackup.enable [config.services.postgresqlBackup.location])
    ++
    (lib.optionals config.services.samba.enable ["/var/lib/samba"])
    ++
    (lib.optionals config.services.rabbitmq.enable [config.services.rabbitmq.dataDir])
    ++
    (lib.optionals config.services.onlyoffice.enable ["/var/lib/onlyoffice" ])
    ++
    (map (borgConfig: borgConfig.borg_base_directory)  (builtins.attrValues config.services.borgmatic.configurations));   
  };
}