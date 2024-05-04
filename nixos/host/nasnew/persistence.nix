
{ inputs, config, pkgs, nixpkgs, lib, ... }:
{
  fileSystems."/persist".neededForBoot = true;
  fileSystems."/nas".neededForBoot = true;
  #fileSystems."/nas".neededForBoot = true;
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
    directories = [
      "/var/lib/acme"
      "/var/lib/nextcloud/data"
      "/var/lib/postgresql"
    ];
  };
}