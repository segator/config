{ config, pkgs, ... }:
{
    sops.secrets.ssh_roche_key = {
      sopsFile = ../../../secrets/users/${config.home.username}/id_rsa_roche;
      format = "binary";
      mode = "0600";
      path = "${config.home.homeDirectory}/.ssh/id_rsa_roche"; 
    };

}

