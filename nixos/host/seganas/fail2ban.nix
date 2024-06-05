{ pkgs, lib, ... }:
{
  services.fail2ban = {
    enable = true;
    bantime = "10m";
    maxretry = 3;
    bantime-increment = {
      enable = true;
      maxtime = "24h";
    };
  };
}