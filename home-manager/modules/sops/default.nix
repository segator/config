{ config, pkgs, ... }:
{
  sops = {
    age.keyFile = "${config.home.homeDirectory}/.secrets/nix/age_user_key.txt";
    #age.sshKeyPaths = [ "/home/user/path-to-ssh-key" ];
    defaultSopsFile = ../../../secrets/users/${config.home.username}/secrets.yaml;
  };
}