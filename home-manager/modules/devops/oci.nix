{ lib,config, pkgs,inputs, ... }:
{
 home.packages = with pkgs; [ oci-cli ];
}