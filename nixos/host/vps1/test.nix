{ inputs, config, pkgs, nixpkgs, lib, ... }:
let
    testFqdn = "test.neries.li";
    rtmpPort = 1935;
in
{
   services.cloudflare-dyndns.domains = [ testFqdn ]; 

  services.nginx.package = with pkgs;
      nginx.override { modules = with nginxModules; [ rtmp ]; };
  networking.firewall.allowedTCPPorts = [  rtmpPort ];
    services.nginx.virtualHosts."${testFqdn}" = {
      enableACME = true;
      forceSSL = true;
      kTLS = true;     
      appendConfig = ''
        rtmp {
            server {
                listen ${rtmpPort};
                chunk_size 4096;
                allow publish 127.0.0.1;
                deny publish all;
                allow play all;
                application live {
                    live on;
                    record off;
                    meta copy;
                }
            }
        }
      '';
    };   
}