{ lib, config, pkgs, ... }:
{
  sops.secrets."hetzner_api_token" = {
    sopsFile = ../../../secrets/infra/hetzner/secrets.yaml;
  };
  programs.bash = lib.mkIf config.programs.bash.enable {
    bashrcExtra = ''
      export HCLOUD_TOKEN=$(cat "${config.sops.secrets."hetzner_api_token".path}")
    '';
  };
  home.packages = with pkgs; [
    hetzner-kube
    hcloud
  ];
}