{ lib, config, pkgs, ... }:
{
  sops.secrets.github_personal_token = { };

  programs.bash = lib.mkIf config.programs.bash.enable {
    bashrcExtra = ''
      export GITHUB_TOKEN=$(cat "${config.sops.secrets.github_personal_token.path}")
    '';
  };

}