{ lib, config, pkgs, ... }:
{
  sops.secrets."hetzner/api_token" = {
    sopsFile = ../../../secrets/infra/secrets.yaml;
  };
  programs.bash = lib.mkIf config.programs.bash.enable {
    bashrcExtra = ''
      export HCLOUD_TOKEN=$(cat "${config.sops.secrets."hetzner/api_token".path}")
    '';
  };
  home.packages = with pkgs; [
    hetzner-kube
    hcloud
  ];
}