{ inputs, config, pkgs, nixpkgs, lib, ... }:
let
    testFqdn = "test.neries.li";
    rtmpPort = 1935;
    hlsPath = "/tmp/hls";
    dashPath = "/tmp/dash";
in
{
  services.cloudflare-dyndns.domains = [ testFqdn ]; 
    systemd.services.nginx.preStart = ''
      mkdir -p ${hlsPath}
      mkdir -p ${dashPath}
    '';
  services.nginx = {
      package = pkgs.nginx.override {
        extraModules = [ pkgs.nginx-rtmp-module ];
      };
      appendConfig = ''
        rtmp {
            server {
                listen 0.0.0.0:${builtins.toString rtmpPort};
                chunk_size 4096;
                allow publish all;
                allow play all;

                application live {                
                    live on;
                    exec_pull ${pkgs.ffmpeg-full}/bin/ffmpeg -re -timeout 5 -cenc_decryption_key dc02a224dce8b8e7a2aa25b2793079c0 -headers http-referer:https://tv.movistar.com.pe/ -headers http-user-agent:Chrome/61.0.3163.100 -headers X-TCDN-token:eyJhbGciOiJFUzI1NiIsImtpZCI6ImI1OGNhNGM0NGFiOTQ0Y2FiY2U4N2FjNGJmZmI4MDNkIiwidHlwIjoiYXQrand0In0.eyJuYmYiOjE3Mjk5NDQwMDIsImV4cCI6MTczMDAzMDQwMiwiaXNzIjoiaHR0cHM6Ly9pZHNlcnZlci5kb2Y2LmNvbSIsImF1ZCI6InRjZG4iLCJjbGllbnRfaWQiOiJtb3Zpc3RhcnBsdXMiLCJzdWIiOiI3WTdrN3I4SzhPOGo4bzk0IiwiYXV0aF90aW1lIjoxNzI5OTQ0MDAyLCJpZHAiOiJtb3Zpc3RhcisiLCJ1aWQiOiJlYXVaTnB3V1FmQ3kxVnhPOVBDdnhiQVJRU3R3MXFSS2l5THBHazNxN2trPSIsImFjYyI6IkQvY2RhTkpZR0psdCt1cFF1QUVtZFVySkx4UTJsd1ExeEc0QlpLMlQwUE09IiwianRpIjoiRUY2NkUwRERGNTAwNzI1ODY4QUY2QjBBRjY4Njc5NEMiLCJpYXQiOjE3Mjk5NDQwMDIsInNjb3BlIjoiY2RuIn0.zCYYctvU--hHWM1vFmZhLJhtiZsxhZoIc0o5PwqjybfuqeFBeTCYUx9ONm97zj8PSlPqGkmbmiMoOu26u8RhIg -i https://01daznliga-dash-movistarplus.emisiondof6.com/manifest.mpd -c:v copy -c:a aac -b:a 128k -threads 0 -rtmp_buffer 1000 -f flv rtmp://localhost/live/laliga
                    record off;
                    hls on;
                    hls_path ${hlsPath};
                    #hls_fragment 5s;
                    #hls_playlist_length 10s;
                    dash on;
                    dash_path /tmp/dash;
                }
            }
        }
      '';
  };
  networking.firewall.allowedTCPPorts = [  rtmpPort ];
    services.nginx.virtualHosts."${testFqdn}" = {
      enableACME = true;
      forceSSL = true;
      kTLS = true;
      locations."/stat" = {
        extraConfig = ''
          rtmp_stat all;
        '';
      };
      locations."/dash" = {
        root = "${dashPath}";
        extraConfig = ''
          add_header Cache-Control no-cache;
          add_header Access-Control-Allow-Origin *;
        '';
      };
      locations."/hls" = {
        # Serve files from the specified path
        root = "${hlsPath}"; # Ensure this matches your hls_path in RTMP config
        # Optionally set caching headers for better performance
        extraConfig = ''
          add_header Cache-Control no-cache;
          add_header Access-Control-Allow-Origin *;
          types {
                application/vnd.apple.mpegurl m3u8;
                video/mp2t ts;
          }
        '';
    };   
  };
  
  systemd.tmpfiles.rules = [
    "d ${hlsPath} 0755 nginx nginx -"
  ];
}