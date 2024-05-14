
{ inputs, config, pkgs, nixpkgs, lib, ... }:
{
      services.smartd = {
        enable = false; # As the nas is a VM for the moment not needed
        defaults.monitored = ''
          -a -o on -S on -n standby,q -s (S/../.././01|L/../../7/04:002) -W 4,40,45
        '';
        notifications = {
          mail = {
            mailer = "${pkgs.mailtelegram}/bin/mail";
            enable = true;
            sender = "root";
            recipient = "root";
          };
          wall.enable = false;
        };
      };
}