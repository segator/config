{ inputs, config, pkgs,  lib, ... }:
{
    services.pcscd.enable = true;
      environment.systemPackages = with pkgs; [
        yubioath-flutter
      ];
}