
{ inputs, config, pkgs, nixpkgs, lib, ... }:
let
    mailtelegram_config_path = "/etc/mailtelegram/mailtelegram.conf";
in
{
    environment.systemPackages = with pkgs; [
        (pkgs.mailtelegram.override { 
          config_source_path = mailtelegram_config_path;
          name = "mail";
          })
    ];

    sops.secrets."telegram/bot_token" = {
        sopsFile = ../../../secrets/common/monitoring.yaml;        
    };
    sops.secrets."telegram/chatid" = { 
        sopsFile = ../../../secrets/common/monitoring.yaml;
    };

    sops.templates."mailtelegram.conf" = {
        path = mailtelegram_config_path;
        content = ''
        opt_telegram_bot_token="${config.sops.placeholder."telegram/bot_token"}"
        opt_telegram_chatid="${config.sops.placeholder."telegram/chatid"}"
        '';
    };
}