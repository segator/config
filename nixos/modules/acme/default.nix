{ inputs, config, pkgs, nixpkgs, lib, ... }:
{
   networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 80 443 ];
  };
  security.acme = {
    defaults = {
      email = "isaac.aymerich@gmail.com";
      # Staging
      #server = "https://acme-staging-v02.api.letsencrypt.org/directory";
      # Prod
      server = "https://acme-v02.api.letsencrypt.org/directory";
    };
    acceptTerms = true;
  };
}