
{ inputs, config, pkgs, nixpkgs, lib, ... }:
let
  nas_snapshot_shares = [ "homes" "crbmc" "photo" "isaacaina" "multimedia" "software" ];
in
{
    services.zfs.autoScrub.enable = true;
    services.zfs.autoScrub.interval = "quarterly";

    # Snapshots
    services.sanoid = {
        enable = true;
        interval = "hourly";

        datasets = builtins.listToAttrs (map (name: {
            name = "nas/${name}";
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
  environment.systemPackages = with pkgs; [
        mailhook
  ];
  services.zfs.zed.settings = {
    #https://github.com/leoj3n/zedhook/blob/master/zedhook
    ZED_DEBUG_LOG = "/tmp/zed.debug.log";
    ZED_EMAIL_ADDR = [ "root" ];
    ZED_EMAIL_PROG = "${pkgs.msmtp}/bin/msmtp";
    ZED_EMAIL_OPTS = "@ADDRESS@";

    ZED_NOTIFY_INTERVAL_SECS = 3600;
    ZED_NOTIFY_VERBOSE = true;

    ZED_USE_ENCLOSURE_LEDS = true;
    ZED_SCRUB_AFTER_RESILVER = true;
  };
  
  # this option does not work; will return error
  services.zfs.zed.enableMail = true;
}