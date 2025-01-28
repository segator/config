{ config, pkgs, ... }:
{
  sops = {
    age.keyFile = "${config.home.homeDirectory}/.secrets/nix/age_user_key.txt";
    #age.sshKeyPaths = [ "/home/user/path-to-ssh-key" ];
    defaultSopsFile = ../../../secrets/users/${config.home.username}/secrets.yaml;
  };

  # home.activation.setupEtc = config.lib.dag.entryAfter [ "writeBoundary" ] ''
  #   /run/current-system/sw/bin/systemctl start --user sops-nix
  # '';
}