
{ inputs, config, pkgs, nixpkgs, lib, ... }:
let  
  kopiaCacheDir = "/var/kopia/cache";
  kopiaCacheLog = "/var/kopia/log";
  backupServerSshPubKey = pkgs.writeText "nuc.keys" ''
    192.168.0.250 ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJEQgvlucZCfPCrkdSHGrQwbNLHjFTzAwZuPg80W9Lcy
    192.168.0.250 ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDy8CVwRW7UXKfXCNyyW2ivSHH9sYIDM4RVjap8P4UnfVgJCzE45UQHhTs9AFW82CV09U/JU+JKIvGNQrlTxpJXNxTqwsJUda+T8vVnRqo+/wWzRyWJO0lOVAJJP5c6LmviJdVgkCdSDfJIbIoRVk0/H8lIJu9/1qftHBQ63wFjQM4mIQrE4aX7DV62jw6RRF0tdYlmI2D3wqow+nlqITF/OtK6R/lO3LikH3MeYZ4QwU6w23ynowxV9h+RV0OmLiemdsP5Sa+Ddu9gnWiM3SdLBHQGFSuFd47dOe1NPp+1jCsbCAc4FfZl9DS0TsfemFFMYy+SCjM0cr7YCwP3sdL75UJ3XuJIKgX321AaEf+7RT/i46KXGX1kqz9ogguAruGF+wKo6X1gb2MhUCcJXzyEEoh0jFfVwXX3au7611A9Vg3PtrTjCHGPCDtNAJNEMOj1Xk/LuAaJjX3gQhAh8KLGzNkgZZWzqvenaEiTlCf05UAMjkI/V1vgbHYDGMkHmzs=
    192.168.0.250 ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBOWPPN/Py2jqrPGj3lJwEONJrEQPHtZmpzhq9rnwX0f3Be4QT6x0dpk4QpUpR/YhCAtXoMB7jiTSjPYNj1UuJZg=
    '';

   repoConfig = pkgs.writeText "repo.config" ''
    {
      "storage": {
        "type": "sftp",
        "config": {
          "path": "/backup/kopia",
          "host": "192.168.0.250",
          "port": 22,
          "username": "root",
          "keyfile": "${config.sops.secrets."kopia-backup-sshkey".path}",
          "knownHostsFile": "${backupServerSshPubKey}",
          "externalSSH": false,
          "sshCommand": "ssh",
          "dirShards": null
        }
      },
      "caching": {
        "cacheDirectory": "${kopiaCacheDir}",
        "maxCacheSize": 5242880000,
        "maxMetadataCacheSize": 5242880000,
        "maxListCacheDuration": 30
      },
      "hostname": "${config.networking.hostName}",
      "username": "root",
      "description": "Backup Repository",
      "enableActions": false,
      "formatBlobCacheDuration": 900000000000
    }
   '';
in
{
  
  environment.systemPackages = with pkgs; [
    kopia
  ];

  sops.secrets."kopia-backup-sshkey" = {
    sopsFile = ../../../secrets/common/kopia-nuc-ssh.key;
    format = "binary";
  };

  sops.secrets.kopia_passphrase = {};

  systemd = {
    timers.kopia-backup = {
      enable = false;
      wantedBy = ["timers.target"];
      partOf = ["kopia-backup.service"];
      timerConfig.OnCalendar = "05:00";
    };
    services.kopia-backup = let
      kopiaOptions = "--progress --config-file ${repoConfig}";
    in {
      serviceConfig = {
        Type = "oneshot";
        Environment = [            
            "KOPIA_CACHE_DIRECTORY=${kopiaCacheDir}"
            "KOPIA_LOG_DIR=${kopiaCacheLog}"
            "KOPIA_CHECK_FOR_UPDATES=false"
            "KOPIA_PERSIST_CREDENTIALS_ON_CONNECT=false"
        ];
      };
      script = ''
        export KOPIA_PASSWORD=$(cat ${config.sops.secrets.kopia_passphrase.path})
        ${pkgs.kopia}/bin/kopia snapshot create ${kopiaOptions} ${lib.concatStringsSep " " config.nas.backup.sourceDirectories}
      '';
    };
  };
}