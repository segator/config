{ config, pkgs, ... }:
{
    sops.secrets.pki_cert9 = {
      sopsFile = ../../../secrets/users/${config.home.username}/pki/cert9.db;
      format = "binary";
      mode = "0600";
      path = "${config.home.homeDirectory}/.pki/nssdb/cert9.db"; 
    };  

    sops.secrets.pki_key4 = {
      sopsFile = ../../../secrets/users/${config.home.username}/pki/key4.db;
      format = "binary";
      mode = "0600";
      path = "${config.home.homeDirectory}/.pki/nssdb/key4.db"; 
    };    

    sops.secrets.pki_pkcs11 = {
      sopsFile = ../../../secrets/users/${config.home.username}/pki/pkcs11.txt;
      format = "binary";
      mode = "0600";
      path = "${config.home.homeDirectory}/.pki/nssdb/pkcs11.txt"; 
    };
}

