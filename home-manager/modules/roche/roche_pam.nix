{ config, pkgs, ... }:
{
    sops.secrets.user_key = {
      sopsFile = ../../../secrets/users/${config.home.username}/${config.home.username}.key;
      format = "binary";
      #path = "%r/.config/rlcaas-roche/${config.home.username}.key"; 
      path = "${config.home.homeDirectory}/.config/rlcaas-roche/${config.home.username}.key"; 
    };

    sops.secrets.user_pem = {
      sopsFile = ../../../secrets/users/${config.home.username}/${config.home.username}.pem;
      format = "binary";
      path = "${config.home.homeDirectory}/.config/rlcaas-roche/${config.home.username}.pem"; 
    };

    sops.secrets.user_p12 = {
      sopsFile = ../../../secrets/users/${config.home.username}/${config.home.username}.p12;
      format = "binary";
      path = "${config.home.homeDirectory}/.config/rlcaas-roche/${config.home.username}.p12"; 
    };

}

