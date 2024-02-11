{ config, pkgs, lib, ... }:
let
  gitlab_token= "${config.home.homeDirectory}/.secrets/home-manager/gitlab_token";
  gitlab_npm_token = "${config.home.homeDirectory}/.secrets/home-manager/gitlab_npm_token";
  github_token = "${config.home.homeDirectory}/.secrets/home-manager/github_token";
  jfrog_navify_user = "${config.home.homeDirectory}/.secrets/home-manager/jfrog_navify_user";
  jfrog_navify_token = "${config.home.homeDirectory}/.secrets/home-manager/jfrog_navify_token";
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


  home.file.".secrets/home-manager/secrets.bashrc" = {
    text=''
    NPM_AUTH_TOKEN=$(cat ${gitlab_npm_token})
    GITLAB_TOKEN=$(cat ${gitlab_token})
    GITHUB_TOKEN=$(cat ${github_token})
    REPOSITORY_USER=$(cat ${jfrog_navify_user})
    REPOSITORY_TOKEN=$(cat ${jfrog_navify_token})
    '';
  };

  home.file.".secrets/home-manager/secrets.fish" = {
    text=''
    set -gx NPM_AUTH_TOKEN $(cat ${gitlab_npm_token})
    set -gx GITLAB_TOKEN $(cat ${gitlab_token})
    set -gx GITHUB_TOKEN $(cat ${github_token})
    set -gx REPOSITORY_USER $(cat ${jfrog_navify_user})
    set -gx REPOSITORY_TOKEN $(cat ${jfrog_navify_token})
    '';
  };

  programs.bash = lib.mkIf config.programs.bash.enable {
    bashrcExtra = ''
      source ${config.home.homeDirectory}/.secrets/home-manager/secrets.bashrc
    '';
  };  

  programs.fish = lib.mkIf config.programs.fish.enable {
    shellInit = ''
      source ${config.home.homeDirectory}/.secrets/home-manager/secrets.fish
    '';
  };
}

