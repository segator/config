{ inputs, config, pkgs,  lib, ... }:
{
  services.openssh = {
  enable = true;
  settings.PasswordAuthentication = true;
  settings.PermitRootLogin = "yes";
  hostKeys = [
    {
      path = "/etc/ssh/ssh_host_ed25519_key";
      type = "ed25519";
    }
  ];
  openFirewall = true;
  };
}