{ inputs, config, pkgs, nixpkgs, lib, ... }:
{

    sops.secrets.nextcloud_admin_password = {
        owner = "nextcloud";
        group = "nextcloud";
        restartUnits = [ "nextcloud-setup.service" ];

    };

    services.nextcloud = {
        enable = true;
        package = pkgs.nextcloud28;
        
        extraAppsEnable = true;
        extraApps = {
            inherit (config.services.nextcloud.package.packages.apps) contacts calendar tasks memories previewgenerator;
        };
        hostName = "cloud.segator.es";
        #config.extraTrustedDomains = [ "116.203.110.163" ];

        # Use HTTPS for links
        https = true;

        # Auto-update Nextcloud Apps
        autoUpdateApps.enable = true;
        # Set what time makes sense for you
        autoUpdateApps.startAt = "05:00:00";
        settings = {
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
            "OC\\Preview\\HEIC"
          ];
        };
          
        maxUploadSize = "32G";
        ## Options for the PHP worker. Extension `smbclient` is necessary for CIFS
        ## external storage. Options `opcache.<whatever>` need to be quoted to have
        ## a dot in the name of the option.
        phpExtraExtensions = p: [ p.smbclient ];
        phpOptions."opcache.interned_strings_buffer" = "16";

    
        config = {
            adminuser = "admin";
            adminpassFile = config.sops.secrets.nextcloud_admin_password.path;

            dbtype = "pgsql";
            dbuser = "nextcloud";
            dbhost = "/run/postgresql";
            dbname = "nextcloud";
            };

            settings = {
            default_phone_region = "ES";

            ## The `file` log type allows reading logs from the NextCloud interface.
/*             logType = "file"; */

            ## Mail configuration
/*             mail_sendmailmode = "smtp";
            mail_from_address = "no-reply";
            mail_domain = "niols.fr"; */

            ## Mail authentication - password in secrets.
            #mail_smtpmode = "smtp";
            /* mail_smtphost = "mail.infomaniak.com";
            mail_smtpsecure = "ssl";
            mail_smtpport = 465;
            mail_smtpauth = 1;
            mail_smtpname = "no-reply@niols.fr"; */
        };
    };

    services.postgresql = {
        enable = true;
        ensureDatabases = [ "nextcloud" ];
        ensureUsers = [{
        name = "nextcloud";
        ensureDBOwnership = true;
        }];
        ## All databases are backed up daily. See `databases.nix`.
    };

    ## Make sure Nextcloud only starts once the database is up.
    systemd.services."nextcloud-setup" = {
        requires = [ "postgresql.service" ];
        after = [ "postgresql.service" ];
    };
}