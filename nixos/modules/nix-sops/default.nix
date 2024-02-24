{ inputs, config, pkgs,  lib, ... }:
{
  #imports = [ <sops-nix/modules/sops> ];
  sops = {
    defaultSopsFile = ../../../secrets/hosts/${config.networking.hostName}/secrets.yaml;
    age.sshKeyPaths = [ /etc/ssh/ssh_host_ed25519_key ];
  };
}
  
