{ self, config, lib, pkgs, ... }:
let
  nextcloudAdminUser = "admin";
  fqdn = "cloud-192.168.0.121.traefik.me";
  occ = lib.getExe config.services.nextcloud.occ;
  exifToolMemories = pkgs.exiftool.overrideAttrs (oldAttrs: rec {
        version = "12.70";
        src = builtins.fetchurl  {
            url = "https://exiftool.org/Image-ExifTool-${version}.tar.gz";
            sha256 = "sha256-TLJSJEXMPj870TkExq6uraX8Wl4kmNerrSlX3LQsr/4=";  # Update the hash accordingly
        };
    }); 
in
{
    sops.secrets.nextcloud_admin_password = {
        owner = "nextcloud";
        group = "nextcloud";
        restartUnits = [ "nextcloud-setup.service" ];

    };
   

  #https://carjorvaz.com/posts/the-holy-grail-nextcloud-setup-made-easy-by-nixos/
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 ];
  };
  security.acme = {
    defaults = {
      email = "isaac.aymerich@gmail.com";
      server = "https://acme-staging-v02.api.letsencrypt.org/directory";
      # prod --> "https://acme-v02.api.letsencrypt.org/directory"
    };
    acceptTerms = true;
  };
  environment.systemPackages = with pkgs; [
    nextcloud-config
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
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedTlsSettings = true;
      virtualHosts = {
        "${fqdn}" = {
          forceSSL = false;
          enableACME = false;
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
      hostName = fqdn;
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
      https = false;
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
        "trusted_domains" = [ fqdn ];
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
          nice_binary = lib.getExe' pkgs.coreutils "nice";
        };

      };
      config = {
        adminuser = nextcloudAdminUser;
        adminpassFile = config.sops.secrets.nextcloud_admin_password.path;

        dbtype = "pgsql";
        dbhost = "/run/postgresql";
        dbname = "nextcloud";
      };
    };
    phpfpm.pools = {
      # add user packages to phpfpm process PATHs, required to find ffmpeg for preview generator
      # beginning taken from https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/web-apps/nextcloud.nix#L985
      nextcloud.phpEnv.PATH = lib.mkForce "/run/wrappers/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin:/usr/bin:/bin:/etc/profiles/per-user/nextcloud/bin";
    };
    postgresql = {
      enable = true;
      package = pkgs.postgresql_16;
      ensureDatabases = [ "nextcloud" ];

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
        ${occ} app:install memories || ${occ} app:enable memories
        ${occ} app:install previewgenerator || ${occ} app:enable previewgenerator
        ${occ} app:install recognize || ${occ} app:enable recognize


        # Memories 
        #${occ} memories:places-setup

        #  Recognize configuration
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
        ${occ} app:disable photos
        ${occ} app:disable activity

        # Missing indices
        ${occ} db:add-missing-indices

        # Enable cron mode (nixos by default enables the systemd cron to 5min but not enabled on the app)
        ${occ} background:cron

        # Configure User Groups
        ${lib.concatStringsSep "\n" (map (groupName: ''                        
                    ${occ} group:list | grep -q "${groupName}" || {
                        echo "group ${groupName} does not exists, creating..."
                        ${occ} group:add "${groupName}"
                    }                                        
              '') 
              (lib.attrNames config.nas.groups))}
        # Configure external mountpoints
      '' + (
      let
          escape = x: builtins.replaceStrings ["/"] [''\\\/''] x;
          rootMountName = "/";
          dataHomesDirectory = config.disko.devices.zpool.nas.datasets.homes.mountpoint+"/$user";
          all_shares = config.nas.shares // {
            "/" = {
              path = config.disko.devices.zpool.nas.datasets.homes.mountpoint+"/$user";
            };
          };
        in
          ''

          # Enable file sharing
          nextcloud_mounts=''$(nextcloud-occ files_external:list --output=json)

          echo "''$nextcloud_mounts" | jq -c '.[]' | while read -r mount; do
              mount_id=$(echo "$mount" | jq -r '.mount_id')
              mount_point=$(echo "$mount" | jq -r '.mount_point')
              echo "Enabling sharing for ''$mount_point (''$mount_id)"
              ${occ} files_external:option ''$mount_id enable_sharing true


              nextcloud-occ files_External:applicable 1 --add-group aymerich --add-group isaacaina
          done
          '');

      requires = ["postgresql.service"];
      after = [ "postgresql.service" ];
    };

  nextcloud-user-setup = {
      enable = true;
      description = "Configure nextcloud users";
      script = (
              let
              userPassword = username: "$(cat ${config.sops.secrets."${username}_password".path})";
              userCommands = lib.mapAttrsToList (username: _:
                    ''                    
                    if ${occ} user:list | grep -q "${username}"; then
                        echo "User ${username} does exists, updating..."
                        OC_PASS="${userPassword username}" ${occ} user:resetpassword --password-from-env segator                        
                    else
                        echo "User ${username} does not exists, creating..."
                        OC_PASS="${userPassword username}" ${occ} user:add ${username} --password-from-env
                    fi           
                    ''
                    ) 
                    config.nas.users;
              groupMembersCommands = groupName: members: 
                    map (member: ''
                      ${occ} group:adduser "${groupName}" "${member}"
                    '') members;
              groupCommands = lib.mapAttrsToList (groupName: group: ''
                    ${lib.concatStringsSep "\n" (groupMembersCommands groupName group.members )}
              '')
              config.nas.groups;  


                  
              in 
              ''
              echo "Configuring users"
              ${lib.concatStringsSep "\n" userCommands}            
              
              echo "Configuring groups members"
              ${lib.concatStringsSep "\n" groupCommands}
              '');

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
}