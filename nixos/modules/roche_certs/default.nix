{ lib, ... }:
{
    security.pki.certificateFiles = lib.filesystem.listFilesRecursive ./certs;
}