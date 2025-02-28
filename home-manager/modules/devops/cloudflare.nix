{ lib, config, pkgs, ... }:
{
  sops.secrets."cloudflare/api_token" = {
    sopsFile = ../../../secrets/infra/secrets.yaml;
  };
  programs.bash = lib.mkIf config.programs.bash.enable {
    bashrcExtra = ''
      export CLOUDFLARE_API_TOKEN=$(cat "${config.sops.secrets."cloudflare/api_token".path}")
    '';
  };
  home.packages = with pkgs; [
    cfssl
  ];
}