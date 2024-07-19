{ inputs, config, pkgs, nixpkgs, lib, ... }:
{

    sops.secrets."proxylive/urlm3u8" = { };
    sops.templates."application.yml" = {
        owner = "docker";
        content = ''
            password = "proxylive/urlm3u8"
    '';
    };
    
    virtualisation.oci-containers = {
        backend = "docker";
        containers = {
            my-spring-app = {
                image = "segator/proxylive:latest"; # The Docker image you want to use
                autoStart = true;

                mounts = [
                    {
                    type = "bind";
                    source = "${appConfig.applicationYml}/application.yml";
                    target = "/config/application.yml";
                    }
                ];

                environment = {
                    SPRING_CONFIG_LOCATION = "file:/config/application.yml";
                };

                ports = [ "8080:8080" ];
            };
        
        };
    };
}