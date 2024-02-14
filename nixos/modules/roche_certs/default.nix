{ lib, ... }:
{
    security.pki.certificateFiles = lib.filesystem.listFilesRecursive ./certs;
    environment.etc = {
      "ssl/Roche/RocheG1G3RootCABundle.crt".source = ./certs/RocheG1G3RootCABundle.crt;
    };
}