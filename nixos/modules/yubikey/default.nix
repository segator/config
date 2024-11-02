{ inputs, config, pkgs,  lib, ... }:
{
    services.pcscd.enable = true;
      environment.systemPackages = with pkgs; [
        pcscliteWithPolkit.out
        yubioath-flutter
        yubikey-personalization
      ];
}