
{ inputs, config, pkgs, nixpkgs, lib, ... }:
let
  nas_snapshot_shares = map (share: share.path) (builtins.attrValues config.nas.shares);
in
{
    services.zfs.autoScrub.enable = true;
    services.zfs.autoScrub.interval = "quarterly";

    # Snapshots
    services.sanoid = {
        enable = true;
        interval = "hourly";

        datasets = builtins.listToAttrs (map (name: {
            inherit name;
            value = {
                useTemplate = [ "nas" ];
            };
        }) nas_snapshot_shares);

        templates.nas = {
            autosnap = true;
            autoprune = true;

            frequently = 0;
            hourly = 1;
            daily = 6;
            weekly = 1;            
            monthly = 12;
            yearly = 2;
        };
  };



  # zfs notifications
  # TODO example https://github.com/JulienMalka/nix-config/blob/eab2d71e07131a28782dd34fb56f8ee68ffc0578/modules/zfs-mails/default.nix#L56
  services.zfs.zed.settings = {
    #https://github.com/leoj3n/zedhook/blob/master/zedhook
    #ZED_DEBUG_LOG = "/tmp/zed.debug.log";
    ZED_EMAIL_ADDR = [ "root" ];
    ZED_EMAIL_PROG = "${pkgs.mailtelegram}/bin/mail";
    ZED_EMAIL_OPTS = "-s 'zfs @SUBJECT@'";

    ZED_NOTIFY_INTERVAL_SECS = 300;
    ZED_NOTIFY_VERBOSE = true;

    #ZED_USE_ENCLOSURE_LEDS = true;
    #ZED_SCRUB_AFTER_RESILVER = true;
  };
  
  # this option does not work; will return error
  services.zfs.zed.enableMail = true;
}