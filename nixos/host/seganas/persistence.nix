
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
    (lib.optionals config.services.nextcloud.enable ["/var/lib/nextcloud"])
    ++
    (lib.optionals config.services.postgresql.enable ["/var/lib/postgresql"])
    ++
    (lib.optionals config.services.samba.enable ["/var/lib/samba"])
    ++
    (lib.optionals config.services.rabbitmq.enable ["/var/lib/rabbitmq"])
    ++
    (lib.optionals config.services.onlyoffice.enable ["/var/lib/onlyoffice" ])
    ++
    (map (borgConfig: borgConfig.borg_cache_directory)  (builtins.attrValues config.services.borgmatic.configurations));   
  };
}