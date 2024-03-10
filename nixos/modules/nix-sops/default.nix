{ inputs, config, pkgs, lib, ... }:
{
  sops = {
    defaultSopsFile = ../../../secrets/hosts/${config.networking.hostName}/secrets.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  };
}
  
