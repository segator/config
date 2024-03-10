
{ inputs, config, pkgs, nixpkgs, lib, ... }:
{

  sops.secrets.backup_borg_passphrase = {
  };

  sops.secrets.backup_homeassistant_webhook = {
  };

  services.borgmatic = {
    enable = true;
    configurations."nas" = {
      source_directories = [ "/nas/homes" "/nas/software" "/nas/isaacaina" ];
      repositories = [
        { label = "unraid-disk"; path = "ssh://root@192.168.1.200/mnt/disks/IsaacBackup/NAS/backup"; }

      ];
      exclude_patterns = [ "re:^.+\.zfs\/.+" ];
      checkpoint_interval = 300;      
      #exclude_if_present = [ ];
      encryption_passcommand = "${pkgs.coreutils}/bin/cat ${config.sops.secrets.backup_borg_passphrase.path}";
      compression = "auto,zstd,10";
      ssh_command = "ssh -i /etc/ssh/ssh_host_ed25519_key";
      keep_daily = 7;
      keep_weekly = 4;
      keep_monthly = 12;
      keep_yearly = 1;
      extra_borg_options = {
        create = "--stats --show-rc --progress";
      };
      checks = [{
        name = "repository";
        frequency = "always";
      }];
      #before_actions = [ "${pkgs.curl}/bin/curl -fss -m 10 --retry 5 -o /dev/null $(${pkgs.coreutils}/bin/cat ${config.age.secrets.picardResticHealthCheckUrl.path})/start" ];
      #after_actions = [ "${pkgs.curl}/bin/curl -fss -m 10 --retry 5 -o /dev/null $(${pkgs.coreutils}/bin/cat ${config.age.secrets.picardResticHealthCheckUrl.path})" ];
      after_backup = [
        "${pkgs.curl}/bin/curl -fss -m 10 --retry 5 -d 'backup completed' -o /dev/null $(${pkgs.coreutils}/bin/cat ${config.sops.secrets.backup_homeassistant_webhook.path})" ];
      after_check = [
        "${pkgs.curl}/bin/curl -fss -m 10 --retry 5 -d 'check completed' -o /dev/null $(${pkgs.coreutils}/bin/cat ${config.sops.secrets.backup_homeassistant_webhook.path})" ];
      on_error = [ 
        "${pkgs.curl}/bin/curl -fss -m 10 --retry 5 -d '{repository}: {error}' -o /dev/null $(${pkgs.coreutils}/bin/cat ${config.sops.secrets.backup_homeassistant_webhook.path})" ];
      #postgresql_databases = [{ name = "all"; pg_dump_command = "${pkgs.postgresql}/bin/pg_dumpall"; pg_restore_command = "${pkgs.postgresql}/bin/pg_restore"; }];
      #pkgs.writeShellScript "batenergy.sh" ''        '' "{repository}" "error"
    };
  };


/*   services.borgbackup.jobs.nas-backup = {
    user = "root";
    paths = ["/nas/homes" "/nas/software" "/nas/isaacaina" ];
    exclude = "re:^.+\.zfs\/.+";
    encryption = {
      mode = "repokey-blake2";
      passCommand = "cat ${config.sops.secrets.backup_borg_passphrase.path}";
    };
    environment.BORG_RSH = "ssh -i /etc/ssh/ssh_host_ed25519_key";
    environment.BORG_CACHE_DIR = "/var/cache/borg";
    repo = "ssh://root@192.168.1.200/mnt/disks/IsaacBackup/NAS/backup";
    compression = "auto,zstd,7";
    startAt = "daily";
    extraCreateArgs = "--verbose --filter AMEx --list --files-cache=mtime,size --stats --show-rc --exclude-caches --progress";
    prune.keep = {
      daily = 7;
      weekly = 1;
      monthly = 1;
    };

    postHook = ''
      cat > /var/log/telegraf/borgbackup-job-${config.networking.hostName}.service <<EOF
      task,frequency=daily last_run=$(date +%s)i,state="$([[ $exitStatus == 0 ]] && echo ok || echo fail)"
      EOF
    '';
  }; */
}