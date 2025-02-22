{ lib,config, pkgs,inputs, ... }:
{
 home.packages = [ (pkgs.callPackage ./oci-cli.nix { }) ];
}