{ inputs, config, pkgs, nixpkgs, lib, ... }:
{
    services = {
        postgresql = {
            enable = true;
            package = pkgs.postgresql_16;
        };
        postgresqlBackup = {
        enable = true;
        };
    };
    nas.backup.sourceDirectories = [config.services.postgresqlBackup.location];
}