{ inputs, config, pkgs,  lib, ... }:
{
    programs.steam = {
        enable = true;
        remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
        dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    };
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
        "steam"
        "steam-original"
        "steam-run"
    ];
    
    #programs.steam.gamescopeSession.enable = true;
    #programs.java.enable = true;
    programs.gamescope = {
      enable = false;
      args = [ "--hdr-enabled" ];
      env = {
        DXVK_HDR = "1";
        ENABLE_GAMESCOPE_WSI = "1";
      };
    };
    environment.systemPackages = with pkgs; [
        steamcmd
    ];
    
}
