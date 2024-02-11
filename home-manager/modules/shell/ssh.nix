
{ config, pkgs, ... }:
{
    # SSH Key
    sops.secrets.ssh_private_key = {
      sopsFile = ../../../secrets/users/${config.home.username}/id_ed25519;
      format = "binary";
      mode = "0600";
      #path = "%r/.config/rlcaas-roche/${config.home.username}.key"; 
      path = "${config.home.homeDirectory}/.ssh/id_ed25519"; 
    };   
}



