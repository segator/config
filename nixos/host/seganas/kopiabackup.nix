
{ inputs, config, pkgs, nixpkgs, lib, ... }:
{

  sops.secrets.backup_homeassistant_webhook = {
  };

  programs.ssh.knownHosts."u399475.your-storagebox.de" = {         
      publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIICf9svRenC/PLKIL9nk6K/pxQgoiFC41wTNvoIncOxs";
  };
  rm /root/.ssh/known_hosts

}

export KOPIA_PASSWORD="dddddddddddddddddddddd"
export KOPIA_CACHE_DIRECTORY="/var/kopia/cache"
export KOPIA_LOG_DIR="/var/kopia/log"

kopia repository connect sftp --host u399475.your-storagebox.de --username u399475 --no-check-for-updates --no-use-keyring --no-persist-credentials  --known-hosts=/root/.ssh/known_hosts --port 23  --path backups/NAS
kopia snapshot create /nas/...
kopia snapshot verify --verify-files-percent=2 --file-parallelism=10 --parallel=10
      

Flags:
      --[no-]help                Show context-sensitive help (also try --help-long and --help-man).
      --[no-]version             Show application version.
      --log-file=LOG-FILE        Override log file.
      --log-dir="/root/.cache/kopia"
                                 Directory where log files should be written. ($KOPIA_LOG_DIR)
      --log-level=info           Console log level
      --file-log-level=debug     File log level
      --[no-]help-full           Show help for all commands, including hidden
      --config-file="repository.config"
                                 Specify the config file to use ($KOPIA_CONFIG_PATH)
  -p, --password=PASSWORD        Repository password. ($KOPIA_PASSWORD)
      --[no-]persist-credentials
                                 Persist credentials ($KOPIA_PERSIST_CREDENTIALS_ON_CONNECT)
      --[no-]use-keyring         Use Gnome Keyring for storing repository password. ($KOPIA_USE_KEYRING)
      --cache-directory=PATH     Cache directory ($KOPIA_CACHE_DIRECTORY)
      -
      --[no-]check-for-updates   Periodically check for Kopia updates on GitHub ($KOPIA_CHECK_FOR_UPDATES)
      --[no-]readonly            Make repository read-only to avoid accidental changes
      --description=DESCRIPTION  Human-readable description of the repository
      --[no-]enable-actions      Allow snapshot actions
      --path=PATH                Path to the repository in the SFTP/SSH server
      --host=HOST                SFTP/SSH server hostname
      --port=22                  SFTP/SSH server port
      --username=USERNAME        SFTP/SSH server username
      --sftp-password=SFTP-PASSWORD
                                 SFTP/SSH server password
      --keyfile=KEYFILE          path to private key file for SFTP/SSH server
      --key-data=KEY-DATA        private key data
      --known-hosts=KNOWN-HOSTS  path to known_hosts file
      --known-hosts-data=KNOWN-HOSTS-DATA
                                 known_hosts file entries
      --[no-]embed-credentials   Embed key and known_hosts in Kopia configuration
      --[no-]external            Launch external passwordless SSH command
      --ssh-command="ssh"        SSH command
      --ssh-args=SSH-ARGS        Arguments to external SSH command
      --[no-]flat                Use flat directory structure
      --max-download-speed=BYTES_PER_SEC
                                 Limit the download speed.
      --max-upload-speed=BYTES_PER_SEC
                                 Limit the upload speed.


  repository.config
  {
  "storage": {
    "type": "sftp",
    "config": {
      "path": "backups/NAS",
      "host": "dddddddddddddddddddddddddddddd",
      "port": 23,
      "username": "xxxxxxxxxxxxx",
      "password": "zzzzzzzzzzzzzzzzzzz",
      "knownHostsFile": "/root/.ssh/known_hosts",
      "externalSSH": false,
      "sshCommand": "ssh",
      "dirShards": null
    }
  },
  "caching": {
    "cacheDirectory": "../../../var/kopia/cache",
    "maxCacheSize": 5242880000,
    "maxMetadataCacheSize": 5242880000,
    "maxListCacheDuration": 30
  },
  "hostname": "seganas",
  "username": "root",
  "description": "a nice description",
  "enableActions": false,
  "formatBlobCacheDuration": 900000000000
}