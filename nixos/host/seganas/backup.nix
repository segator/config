
{ inputs, config, pkgs, nixpkgs, lib, ... }:
{

  sops.secrets.backup_borg_passphrase = {
  };

  sops.secrets.backup_homeassistant_webhook = {
  };

  programs.ssh.knownHosts."192.168.1.200" = {         
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM+I/vuw/urVmiFuAnYcxlt8pXbecvMsfIaumiXQz+g/";
  };

  services.borgmatic = {
    enable = true;
    configurations."nas" = {
      source_directories = config.nas.backup.sourceDirectories;
      repositories = [
        { 
          label = "unraid-disk";
          path = "ssh://root@192.168.1.200/mnt/user/nas_backup"; 
        }
      ];
      exclude_patterns = [ "re:^.+\.zfs\/.+" ];
      checkpoint_interval = 300;      
      encryption_passcommand = "${pkgs.coreutils}/bin/cat ${config.sops.secrets.backup_borg_passphrase.path}";
      compression = "auto,zstd,10";
      ssh_command = "ssh -i /etc/ssh/ssh_host_ed25519_key";
      keep_daily = 7;
      keep_weekly = 4;
      keep_monthly = 12;
      keep_yearly = 1;
      borg_cache_directory = "/var/borg/cache";
      extra_borg_options = {
        create = "--stats --show-rc --progress";
      };
      checks = [{
        name = "repository";
        frequency = "always";
      }];
      after_backup = [
        "${pkgs.curl}/bin/curl -fss -m 10 --retry 5 -d 'backup completed' -o /dev/null $(${pkgs.coreutils}/bin/cat ${config.sops.secrets.backup_homeassistant_webhook.path})" ];
      after_check = [
        "${pkgs.curl}/bin/curl -fss -m 10 --retry 5 -d 'check completed' -o /dev/null $(${pkgs.coreutils}/bin/cat ${config.sops.secrets.backup_homeassistant_webhook.path})" ];
      on_error = [ 
        "${pkgs.curl}/bin/curl -fss -m 10 --retry 5 -d '{repository}: {error}' -o /dev/null $(${pkgs.coreutils}/bin/cat ${config.sops.secrets.backup_homeassistant_webhook.path})" ];
    };
  };
}