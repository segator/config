{ config, pkgs, lib, ... }:
let
  gitlab_token= "${config.home.homeDirectory}/.secrets/home-manager/gitlab_token";
  gitlab_npm_token = "${config.home.homeDirectory}/.secrets/home-manager/gitlab_npm_token";
  github_token = "${config.home.homeDirectory}/.secrets/home-manager/github_token";
  jfrog_navify_user = "${config.home.homeDirectory}/.secrets/home-manager/jfrog_navify_user";
  jfrog_navify_token = "${config.home.homeDirectory}/.secrets/home-manager/jfrog_navify_token";
  roche_user_path = "${config.home.homeDirectory}/.secrets/home-manager/roche_user";
  roche_pass_path = "${config.home.homeDirectory}/.secrets/home-manager/roche_pass";
  roche_aws_account_alias = {
    "ni-dev-mfc" = "arn:aws:iam::161629962181:role/Roche/Products/NIB/NIBDevOps";
    "ni-dev-sandbox" = "arn:aws:iam::153050842925:role/Roche/Products/NIB/NIBDevOps";
    "ni-live" = "arn:aws:iam::296370534383:role/Roche/Products/NIB/NIBDevOps";
    "migration-dev" = "arn:aws:iam::891612565494:role/Roche/Products/NIB/NIBDevOps";
    "ni-network" = "arn:aws:iam::897729119902:role/Roche/Products/NIBACKEND/NIBACKENDDevOps";
    "ni-qa" = "arn:aws:iam::340747948655:role/Roche/Products/NIB/NIBDevOps";
    "ni-stage" = "arn:aws:iam::957086612114:role/Roche/Products/NIB/NIBDevOps";
  };
in
{
  sops.secrets.gitlab_token = {
    path=gitlab_token;
   };
  sops.secrets.gitlab_npm_token = { 
    path=gitlab_npm_token;
  };
  sops.secrets.github_token = {
    path = github_token;
   };
  sops.secrets.jfrog_navify_user = {
    path = jfrog_navify_user;
   };
  sops.secrets.jfrog_navify_token = { 
    path = jfrog_navify_token;
  };
  sops.secrets.roche_user = { 
    path = roche_user_path;
  };
  sops.secrets.roche_pass = { 
    path = roche_pass_path;
  };


  home.file.".secrets/home-manager/secrets.bashrc" = lib.mkIf config.programs.bash.enable {
    text=''
    NPM_AUTH_TOKEN=$(cat ${gitlab_npm_token})
    GITLAB_TOKEN=$(cat ${gitlab_token})
    GITHUB_TOKEN=$(cat ${github_token})
    REPOSITORY_USER=$(cat ${jfrog_navify_user})
    REPOSITORY_TOKEN=$(cat ${jfrog_navify_token})

    #NI especific
    TF_REGISTRY_TOKEN=$(cat ${gitlab_token})
    TF_TOKEN_CODE_ROCHE_COM=$(cat ${gitlab_token})
    TG_TF_REGISTRY_TOKEN=$(cat ${gitlab_token})
    '';
  };

  home.file.".secrets/home-manager/secrets.fish" = lib.mkIf config.programs.fish.enable {
    text=''
    set -gx NPM_AUTH_TOKEN $(cat ${gitlab_npm_token})
    set -gx GITLAB_TOKEN $(cat ${gitlab_token})
    set -gx GITHUB_TOKEN $(cat ${github_token})
    set -gx REPOSITORY_USER $(cat ${jfrog_navify_user})
    set -gx REPOSITORY_TOKEN $(cat ${jfrog_navify_token})

    #NI especific
    set -gx TF_TOKEN_CODE_ROCHE_COM $(cat ${gitlab_token})
    set -gx TG_TF_REGISTRY_TOKEN $(cat ${gitlab_token})
    '';
  };

  programs.bash = lib.mkIf config.programs.bash.enable {
    bashrcExtra = ''
      source ${config.home.homeDirectory}/.secrets/home-manager/secrets.bashrc
      export PATH=$PATH:/home/${config.home.username}/.local/bin
    '';
    shellAliases = lib.mapAttrs' (accountName: v: 
      { 
        name = "aws-${accountName}"; 
        value="navify-aws-sso-login --login-alias ${accountName} --username $(cat ${roche_user_path}) --password $(cat ${roche_pass_path})  --write-credentials ${accountName} && export AWS_PROFILE=${accountName}";
      }
    ) roche_aws_account_alias;
  };  

  programs.fish = lib.mkIf config.programs.fish.enable {
    shellInit = ''
      source ${config.home.homeDirectory}/.secrets/home-manager/secrets.fish
      set -gx PATH $PATH:/home/aymerici/.local/bin
    '';
    shellAliases = lib.mapAttrs' (accountName: v: 
      { 
        name = "aws-${accountName}"; 
        value="navify-aws-sso-login --login-alias ${accountName} --username $(cat ${roche_user_path}) --password $(cat ${roche_pass_path})  --write-credentials ${accountName} && set -gx AWS_PROFILE=${accountName}";
      }
    ) roche_aws_account_alias;
  };

  # Navify AWS SSO alias file
  home.file.".navify/aws-sso.yml".  text = ''
    accounts:
    ${lib.concatMapStrings (accountName: 
    "  ${accountName}:\n    login_role: ${roche_aws_account_alias.${accountName}}\n") (builtins.attrNames roche_aws_account_alias)}
  '';

}

