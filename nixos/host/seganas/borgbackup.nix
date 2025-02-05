
{ inputs, config, pkgs, nixpkgs, lib, ... }:
{

  sops.secrets.backup_borg_passphrase = {
  };

  sops.secrets.backup_homeassistant_webhook = {
  };

  programs.ssh.knownHosts."[192.168.1.200]:2222" = {         
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMNRFmPGM2kzIBS3ntZ1Lm7lGLEMYG9P7cNmHpOHJOHQ root@58b227ebebb1";
  };

  environment.systemPackages = with pkgs; [
    xxHash
  ];

  
  environment.shellAliases = {
    # required for spot check
    xxh64sum = "xxhsum -H1";
  };
  

  services.borgmatic = {
    enable = true;
    configurations."nas" = {
      source_directories = config.nas.backup.sourceDirectories;
      repositories = [
        { 
          label = "unraid-disk";
          path = "ssh://borg@192.168.1.200:2222/backup/seganas"; 
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
      borg_base_directory = "/var/borg";
      borgmatic_source_directory = "/var/borgmatic";
      extra_borg_options = {
        #create = "--stats --show-rc --progress";
      };
      checks = [
      {
        name = "repository";
        frequency = "1 month";
      }
      {
        name = "archives";
        frequency = "2 months";
      }
      # {
      #   name = "spot";
      #   count_tolerance_percentage = 10;
      #   data_sample_percentage = 1;
      #   data_tolerance_percentage = 0.5;
      #   frequency = "1 month";
      # }
      ];
      after_backup = [
        "${pkgs.curl}/bin/curl -fss -m 10 --retry 5 -d 'backup completed' -o /dev/null $(${pkgs.coreutils}/bin/cat ${config.sops.secrets.backup_homeassistant_webhook.path})" ];
      after_check = [
        "${pkgs.curl}/bin/curl -fss -m 10 --retry 5 -d 'check completed' -o /dev/null $(${pkgs.coreutils}/bin/cat ${config.sops.secrets.backup_homeassistant_webhook.path})" ];
      on_error = [ 
        "${pkgs.curl}/bin/curl -fss -m 10 --retry 5 -d '{repository}: {error}' -o /dev/null $(${pkgs.coreutils}/bin/cat ${config.sops.secrets.backup_homeassistant_webhook.path})" ];
    };
  };
}