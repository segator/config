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

  rocheAliases = pkgs.writeShellScriptBin "roche-aliases"
  (''
      source ${config.home.homeDirectory}/.bashrc

      export IN_ROCHE_SHELL=1
      export NPM_AUTH_TOKEN=$(cat "${gitlab_npm_token}")
      export GITLAB_TOKEN=$(cat "${gitlab_token}")
      export GITHUB_TOKEN=$(cat "${github_token}")
      export REPOSITORY_USER=$(cat "${jfrog_navify_user}")
      export REPOSITORY_TOKEN=$(cat "${jfrog_navify_token}")

      # Terraform-related variables
      export TF_VAR_git_token=$(cat "${config.sops.secrets.github_personal_token.path}")
      export TF_REGISTRY_TOKEN=$(cat "${gitlab_token}")
      export TF_TOKEN_CODE_ROCHE_COM=$(cat "${gitlab_token}")
      export TG_TF_REGISTRY_TOKEN=$(cat "${gitlab_token}")

      # Navify aws sso
      if ! pip3 list | awk '/^navify-aws-sso-login[[:space:]]/{found=1; exit} END{exit !found}'; then
        echo "navify-aws-sso-login is not installed. Installing..."
        pip3 install --user --break-system-packages navify-aws-sso-login --extra-index-url "https://__token__:$GITLAB_TOKEN@code.roche.com/api/v4/projects/10440/packages/pypi/simple"
      fi

      ${lib.concatStringsSep "\n" (
        lib.mapAttrsToList (accountName: v:
          ''
            alias aws-${accountName}="navify-aws-sso-login --login-alias ${lib.escapeShellArg accountName} --username \$(cat ${lib.escapeShellArg roche_user_path}) --password \$(cat ${lib.escapeShellArg roche_pass_path}) --write-credentials ${lib.escapeShellArg accountName} && export AWS_PROFILE=${lib.escapeShellArg accountName}"
          ''
        ) roche_aws_account_alias
      )}
    '');
  rocheShell = pkgs.writeShellScriptBin "roche-shell" ''
     exec ${pkgs.bashInteractive}/bin/bash --rcfile ${rocheAliases}/bin/roche-aliases "$@"
   '';
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

  home.packages = [ rocheShell ];


 programs.starship = lib.mkIf config.programs.starship.enable {
    settings = {
      custom.roche_shell = {
        when = "[[ -n $IN_ROCHE_SHELL ]]";
        symbol = "🏥";
        style = "bold blue";
        format = "[$symbol roche-shell]($style)";
      };
    };
 };

#   home.activation.installNavifyAwsSsoLogin =
#     lib.hm.dag.entryAfter [ "writeBoundary" "sops-secrets" ] ''
#       export GITLAB_TOKEN=$(cat ${gitlab_token})
#       pip install navify-aws-sso-login \
#       --user --extra-index-url "https://__token__:$GITLAB_TOKEN@code.roche.com/api/v4/projects/10440/packages/pypi/simple"
#       navify-aws-sso-login
#     '';
  home.sessionPath = [ "$HOME/.local/bin/" ];

  programs.bash = lib.mkIf config.programs.bash.enable {
    shellAliases = {
        "rs" = "roche-shell";
      };
  };


  # Navify AWS SSO alias file
  home.file.".navify/aws-sso.yml".  text = ''
    accounts:
    ${lib.concatMapStrings (accountName: 
    "  ${accountName}:\n    login_role: ${roche_aws_account_alias.${accountName}}\n") (builtins.attrNames roche_aws_account_alias)}
  '';

}

