{ lib,config, pkgs,inputs, ... }:
let
 oci_cli = (pkgs.callPackage ./oci-cli.nix { });
in
{
 home.packages = [
 (pkgs.writeShellScriptBin "oci" ''
     export OCI_CLI_SUPPRESS_FILE_PERMISSIONS_WARNING=True
     export SUPPRESS_LABEL_WARNING=True
     exec ${oci_cli}/bin/oci "$@"
   '')
  ];
   sops.secrets."oci_api_key_public" = {
     format = "binary";
     path = "${config.home.homeDirectory}/.oci/sessions/DEFAULT/oci_api_key_public.pem";
     sopsFile = ../../../secrets/infra/oraclecloud/oci_api_key_public.pem;
   };
   sops.secrets.oci_api_key = {
    format = "binary";
    path = "${config.home.homeDirectory}/.oci/sessions/DEFAULT/oci_api_key.pem";
    sopsFile = ../../../secrets/infra/oraclecloud/oci_api_key.pem;
   };
   sops.secrets."fingerprint" = {
     sopsFile = ../../../secrets/infra/oraclecloud/config.yaml;
   };
   sops.secrets."tenancy" = {
     sopsFile = ../../../secrets/infra/oraclecloud/config.yaml;
   };
   sops.secrets."region" = {
     sopsFile = ../../../secrets/infra/oraclecloud/config.yaml;
    };
    sops.secrets."user" = {
     sopsFile = ../../../secrets/infra/oraclecloud/config.yaml;
    };
    sops.templates."config" = {
    path = "${config.home.homeDirectory}/.oci/config";
    content = ''
    [DEFAULT]
    user=${config.sops.placeholder."user"}
    fingerprint=${config.sops.placeholder."fingerprint"}
    key_file=${config.sops.secrets.oci_api_key.path}
    tenancy=${config.sops.placeholder."tenancy"}
    region=${config.sops.placeholder."region"}

    '';
    };
    #security_token_file=${config.sops.secrets.token.path}
}