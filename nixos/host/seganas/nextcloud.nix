{ self, config, lib, pkgs, ... }:
let
  nextcloudAdminUser = "admin";
  nextcloudFqdn = "cloud.segator.es";
  officeFqdn = "office.segator.es";
  occ = lib.getExe config.services.nextcloud.occ;
  exifToolMemories = pkgs.exiftool.overrideAttrs (oldAttrs: rec {
        version = "12.70";
        src = builtins.fetchurl  {
            url = "https://exiftool.org/Image-ExifTool-${version}.tar.gz";
            sha256 = "sha256-TLJSJEXMPj870TkExq6uraX8Wl4kmNerrSlX3LQsr/4=";  # Update the hash accordingly
        };
    }); 
  databaseName = "nextcloud";
  nextcloudDataDir = config.services.nextcloud.datadir + "/data";


in
{
  my.monitoring.logs = [{
      name = "nextcloud";
      path = nextcloudDataDir + "/nextcloud.log";
    }];
  services.prometheus.exporters.nextcloud = {
    enable = true;
    username = nextcloudAdminUser;
    passwordFile = config.sops.secrets.nextcloud_admin_password.path;
    url = "https://${config.services.nextcloud.hostName}";
    group = "nextcloud";
  };
  my.monitoring.prom-exporters = [
    {
      name = "nextcloud-exporter";
      target = "127.0.0.1:${builtins.toString config.services.prometheus.exporters.nextcloud.port}";
    }
  ];

  nas.backup.sourceDirectories = [nextcloudDataDir];

  sops.secrets.nextcloud_admin_password = {
    owner = "nextcloud";
    group = "nextcloud";
    mode = "0440";
    restartUnits = [ "nextcloud-setup.service" ];
  };

  services.cloudflare-dyndns.domains = [ nextcloudFqdn officeFqdn ]; 

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 ];
  };
  security.acme = {
    defaults = {
      email = "isaac.aymerich@gmail.com";
      # Staging
      #server = "https://acme-staging-v02.api.letsencrypt.org/directory";
      # Prod
      server = "https://acme-v02.api.letsencrypt.org/directory";
    };
    acceptTerms = true;
  };
  environment.systemPackages = with pkgs; [
    # for nextcloud memories
    exifToolMemories
    exif
    ffmpeg-headless
    perl
    #perl536Packages.ImageExifTool
    
    # for recognize
    gnumake # installation requirement
    nodejs_20 # runtime and installation requirement
    nodejs_20.pkgs.node-pre-gyp # installation requirement
    python3 # requirement for node-pre-gyp otherwise fails with exit code 236
    util-linux # runtime requirement for taskset
  ];

  services = {
    nginx = {
      virtualHosts = {
        "${nextcloudFqdn}" = {
          forceSSL = true;
          enableACME = true;
          # From [1] this should fix downloading of big files. [2] seems to indicate that buffering
          # happens at multiple places anyway, so disabling one place should be okay.
          extraConfig = ''
            proxy_buffering off;
          '';
        };

        # "office-test.segator.es" = {
        #   forceSSL = true;
        #   enableACME = true;
        # };
      };
    };


    nextcloud = {
      enable = true;
      hostName = nextcloudFqdn;
      package = pkgs.nextcloud29;
      autoUpdateApps = {
        enable = true;
        startAt = "22:35";
      };
      # Let NixOS install and configure the database automatically.
      database.createLocally = true;
      # Let NixOS install and configure Redis caching automatically.
      configureRedis = true;
      #caching.redis = true;
      #caching.apcu = false;
      webfinger = true;
      # Increase the maximum file upload size to avoid problems uploading videos.
      maxUploadSize = "16G";
      https = true;
      extraAppsEnable = false;
      appstoreEnable = true;
      # extraApps = with config.services.nextcloud.package.packages.apps; {
      #   # List of apps we want to install and are already packaged ins
      #   # https://github.com/NixOS/nixpkgs/blob/master/pkgs/servers/nextcloud/packages/nextcloud-apps.json
      #   inherit  mail maps notes tasks previewgenerator memories; # onlyoffice calendar contacts
      #   recognize = pkgs.fetchNextcloudApp rec {
      #     sha256 = "sha256-ziUc4J2y1lW1BwygwOKedOWbeAnPpBDwT9wh35R0MYk=";
      #     url = "https://github.com/nextcloud/recognize/releases/download/v6.1.1/recognize-6.1.1.tar.gz";
      #     license = "gpl3";
      #     appName = "recognize";
      #     appVersion = "6.1.1";
      #   };
      # };
      phpOptions = {
        "opcache.interned_strings_buffer" = "48";
        "opcache.jit" = 1255;
        "opcache.jit_buffer_size" = "128M";
      };
      phpExtraExtensions = ex: [ ex.zip ex.zlib ex.tidy ex.smbclient ];
      settings = {
        maintenance_window_start = 4;
        "trusted_domains" = [ nextcloudFqdn ];
        "trusted_proxies" = [ "127.0.0.1" ];
        overwriteProtocol = "http";
        "localstorage.umask" = "0007";
        default_phone_region = "ES";
        log_type = "file";
        enabledPreviewProviders = [
          "OC\\Preview\\BMP"
          "OC\\Preview\\GIF"
          "OC\\Preview\\JPEG"
          "OC\\Preview\\Krita"
          "OC\\Preview\\MarkDown"
          "OC\\Preview\\MP3"
          "OC\\Preview\\OpenDocument"
          "OC\\Preview\\PNG"
          "OC\\Preview\\TXT"
          "OC\\Preview\\XBitmap"
          "OC\\Preview\\Image"
          "OC\\Preview\\HEIC"
          "OC\\Preview\\TIFF"
          "OC\\Preview\\Movie"
        ];
        allow_user_to_change_display_name = false;
        lost_password_link = "disabled";
        jpeg_quality = 60;
        preview_max_filesize_image = 128; # MB
        preview_max_memory = 512; # MB
        preview_max_x = 2048; # px
        preview_max_y = 2048; # px
        # More info https://github.com/Shawn8901/nix-configuration/blob/8b59d8953e7cb1fd38ec6987bbd18f05406d0ace/modules/nixos/private/nextcloud/memories.nix
        "memories.exiftool" = lib.getExe exifToolMemories;
        "memories.vod.ffmpeg" = lib.getExe pkgs.ffmpeg-headless;
        "memories.vod.ffprobe" = "${pkgs.ffmpeg-headless}/bin/ffprobe";
        recognize = {
          #Not seems to work :( for now I set it by hand in the UI, ugly..
          #nice_binary = lib.getExe' pkgs.coreutils "nice";
          #node_binary = lib.getExe' pkgs.nodejs_20 "node";
        };

      };
      config = {
        adminuser = nextcloudAdminUser;
        adminpassFile = config.sops.secrets.nextcloud_admin_password.path;

        dbtype = "pgsql";
        dbhost = "/run/postgresql";
        dbname = databaseName;
      };
    };
    phpfpm.pools = {
      # add user packages to phpfpm process PATHs, required to find ffmpeg for preview generator
      # beginning taken from https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/web-apps/nextcloud.nix#L985
      nextcloud.phpEnv.PATH = lib.mkForce "/run/wrappers/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin:/usr/bin:/bin:/etc/profiles/per-user/nextcloud/bin";
    };
    postgresql = {
      ensureDatabases = [ databaseName ];
    };

    postgresqlBackup = {
      databases = [ databaseName ];
    };
    onlyoffice = {
      enable = false;
      hostname = "office-192.168.0.121.traefik.me";
    };
  };
  systemd.services = {
    nextcloud-setup = {
      script = ''
        # Installing extra apps
        ${occ} app:install files_external || ${occ} app:enable files_external
        ${occ} app:install suspicious_login || ${occ} app:enable suspicious_login
        ${occ} app:install bruteforcesettings || ${occ} app:enable bruteforcesettings
        ${occ} app:install tasks || ${occ} app:enable tasks
        #${occ} app:install photos || ${occ} app:enable photos
        ${occ} app:install memories || ${occ} app:enable memories
        ${occ} app:install previewgenerator || ${occ} app:enable previewgenerator
        ${occ} app:install recognize || ${occ} app:enable recognize
        



        # Memories 
        #${occ} memories:places-setup

        # Recognize configuration
        if [[ ! -e "${config.services.nextcloud.datadir}/store-apps/recognize/node_modules/@tensorflow/tfjs-node/lib/napi-v8/tfjs_binding.node" ]]; then
            if [[ -d "${config.services.nextcloud.datadir}/store-apps/recognize/node_modules/" ]]; then
              cd "${config.services.nextcloud.datadir}/store-apps/recognize/node_modules/"
              ${pkgs.nodejs_20}/bin/npm rebuild @tensorflow/tfjs-node --build-addon-from-source
            fi
        fi
        mkdir -p "${config.services.nextcloud.datadir}/store-apps/recognize/models"
        if [ -z "$(ls -A "${config.services.nextcloud.datadir}/store-apps/recognize/models")" ]; then
          ${occ} recognize:download-models
        fi

        # Disable default apps
        ${occ} app:disable dashboard
        ${occ} app:disable comments
        #${occ} app:disable photos
        ${occ} app:disable activity

        # Missing indices
        ${occ} db:add-missing-indices

        # Enable cron mode (nixos by default enables the systemd cron to 5min but not enabled on the app)
        ${occ} background:cron
        ''
        + 
        (
          let
            nextcloudGroupConfig = pkgs.writeText "nextcloud-group-config.yaml" (lib.generators.toYAML {} {
              groups = config.nas.groups;
            });
          in
          '' 
        # Configure groups
        OCC_COMMAND="${occ}" CONFIG_PATH="${nextcloudGroupConfig}" ${pkgs.nextcloud-config}/bin/nextcloud-group.py
        '')
        + 
        (
          let
            nextcloudShareConfig = pkgs.writeText "nextcloud-share-config.yaml" (lib.generators.toYAML {} {
              shares = config.nas.shares;
            });
          in
        '' 
        # Configure external shares
        OCC_COMMAND="${occ}" CONFIG_PATH="${nextcloudShareConfig}" ${pkgs.nextcloud-config}/bin/nextcloud-share.py
        '');

      requires = ["postgresql.service"];
      after = [ "postgresql.service" ];
    };

  nextcloud-user-setup = {
      enable = true;
      description = "Configure nextcloud users";
      environment = {
        OCC_COMMAND=occ;
        CONFIG_PATH=pkgs.writeText "nextcloud-user-config.yaml" (lib.generators.toYAML {} {
              groups = config.nas.groups;
              users = config.nas.users;
            });
      };
      script = "${pkgs.nextcloud-config}/bin/nextcloud-user.py"; 
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
      requires = [ "nextcloud-setup.service" ];
      restartIfChanged = true;
      wantedBy = [ "nextcloud-setup.service" ];
      after = [ "nextcloud-setup.service" ];
    };

    nextcloud-cron-preview-generator = {
      environment.NEXTCLOUD_CONFIG_DIR = "${config.services.nextcloud.datadir}/config";
      serviceConfig = {
        ExecStart = "${occ} preview:pre-generate";
        Type = "oneshot";
        User = "nextcloud";
      };
    };
  };
  systemd.timers = {
    nextcloud-cron-preview-generator = {
      timerConfig = {
        OnUnitActiveSec = "5m";
        Unit = "nextcloud-cron-preview-generator.service";
      };
      wantedBy = [ "timers.target" ];
    };
  };
  services.fail2ban = {
    jails.nextcloud.settings = {
      enabled = true;
      port = "http,https";
      filter = "nextcloud[journalmatch=_SYSTEMD_UNIT=phpfpm-nextcloud.service]";
    };
  };
  environment.etc."fail2ban/filter.d/nextcloud.conf".text = ''
    [INCLUDES]
    before = common.conf
    after = nextcloud.local

    [Definition]
    _groupsre = (?:(?:,?\s*"\w+":(?:"[^"]+"|\w+))*)
    failregex = ^%(__prefix_line)s\{%(_groupsre)s,?\s*"remoteAddr":"<HOST>"%(_groupsre)s,?\s*"message":"Login failed:
                ^%(__prefix_line)s\{%(_groupsre)s,?\s*"remoteAddr":"<HOST>"%(_groupsre)s,?\s*"message":"Trusted domain error.
    datepattern = ,?\s*"time"\s*:\s*"%%Y-%%m-%%d[T ]%%H:%%M:%%S(%%z)?"
  '';
}



