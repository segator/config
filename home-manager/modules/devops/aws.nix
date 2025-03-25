{ lib,config, pkgs,inputs, ... }:
let
    aws_profile_name="segator";
in
{
  sops.secrets."aws_access_key" = {
    sopsFile = ../../../secrets/infra/aws/secrets.yaml;
  };
  sops.secrets."aws_secret_access_key" = {
      sopsFile = ../../../secrets/infra/aws/secrets.yaml;
    };

    #activation script to configure the aws segator account
    home.activation."${aws_profile_name}_aws_configure" = lib.hm.dag.entryAfter [ "writeBoundary" "sops-secrets" ]
    ''
    ${pkgs.awscli2}/bin/aws configure --profile ${aws_profile_name} set region eu-central-1
    ${pkgs.awscli2}/bin/aws configure --profile ${aws_profile_name} set aws_access_key_id $(cat ${config.sops.secrets."aws_access_key".path})
    ${pkgs.awscli2}/bin/aws configure --profile ${aws_profile_name} set aws_secret_access_key $(cat ${config.sops.secrets."aws_secret_access_key".path})
    '';

    programs.bash = lib.mkIf config.programs.bash.enable {
        shellAliases =
          {
            "aws-${aws_profile_name}"="export AWS_PROFILE=${aws_profile_name}";
          };
      };
}