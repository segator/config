{ config, pkgs, lib, ... }:

let
  # Load secrets directly using sops-nix.
  rabbitMQPort = 5672;
  secrets = pkgs.sops-nix.secrets {
    rabbitmqUser = "./secrets.yaml#rabbitmq.user";
    rabbitmqPassword = "./secrets.yaml#rabbitmq.password";
    postgresPassword = "./secrets.yaml#postgres.password";
    webToken = "./secrets.yaml#web_token";
  };
in
{
  sops.secrets."rabbitmq/user" = { };
  sops.secrets."rabbitmq/password" = { };
  sops.templates."rabbitmq.env.secret".content = ''
    RABBITMQ_DEFAULT_USER = "${config.sops.placeholder."rabbitmq/user"}"
    RABBITMQ_DEFAULT_PASS = "${config.sops.placeholder."rabbitmq/password"}"
  '';
  # Enable OCI containers in NixOS
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      # Define the "server" container
    #   server = {
    #     image = "ghcr.io/pando85/gearr:latest-server";
    #     ports = ["8080:8080"];
    #     environment = {
    #       LOG_LEVEL = "DEBUG";
    #       BROKER_HOST = "rabbitmq";
    #       BROKER_USER = secrets.rabbitmqUser;
    #       BROKER_PASSWORD = secrets.rabbitmqPassword;
    #       DATABASE_HOST = "postgres";
    #       DATABASE_USER = "postgres";
    #       DATABASE_PASSWORD = secrets.postgresPassword;
    #       DATABASE_DATABASE = "gearr";
    #       SCHEDULER_DOMAIN = "http://server:8080";
    #       SCHEDULER_MINFILESIZE = "100";
    #       WEB_TOKEN = secrets.webToken;
    #     };
    #     volumes = [
    #       {
    #         source = "./demo-files";
    #         target = "/data/current";
    #         readOnly = true;
    #       }
    #     ];
    #     dependsOn = [ "postgres" "rabbitmq" ];
    #   };

    #   # Define the "postgres" container
    #   postgres = {
    #     image = "postgres:latest";
    #     ports = ["5432:5432"];
    #     environment = {
    #       POSTGRES_DB = "gearr";
    #       POSTGRES_USER = "postgres";
    #       POSTGRES_PASSWORD = secrets.postgresPassword;
    #     };
    #   };

      # Define the "rabbitmq" container
      rabbitmq = {
        image = "rabbitmq:3-management";
        ports = ["${builtins.toString rabbitMQPort}:${builtins.toString rabbitMQPort}"];
        environmentFiles = [ "${config.sops.templates."rabbitmq.env.secret".path}" ];
      };

      # Define the "worker" container
    #   worker = {
    #     image = "ghcr.io/pando85/gearr:latest-worker";
    #     command = [
    #       "--log-level" "debug"
    #       "--broker.host" "rabbitmq"
    #       "--broker.user" secrets.rabbitmqUser
    #       "--broker.password" secrets.rabbitmqPassword
    #       "--worker.acceptedJobs" "encode"
    #       "--worker.pgsJobs" "1"
    #       "--worker.maxPrefetchJobs" "3"
    #     ];
    #     dependsOn = [ "rabbitmq" "server" ];
    #   };

    #   # Define the "worker-pgs" container
    #   worker-pgs = {
    #     image = "ghcr.io/pando85/gearr:latest-worker-pgs";
    #     command = [
    #       "--log-level" "debug"
    #       "--broker.host" "rabbitmq"
    #       "--broker.user" secrets.rabbitmqUser
    #       "--broker.password" secrets.rabbitmqPassword
    #       "--worker.pgsJobs" "1"
    #       "--worker.acceptedJobs" "pgstosrt"
    #     ];
    #     dependsOn = [ "rabbitmq" "server" ];
    #   };
    };
  };

  # Open required firewall ports for RabbitMQ
  networking.firewall.allowedTCPPorts = [ rabbitMQPort ];
}