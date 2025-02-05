{ config, pkgs,inputs, ... }:
let
  krewKubectl = inputs.krew2nix.packages."x86_64-linux".kubectl;
in
{  
  home.packages = with pkgs; [
      devbox
      lazydocker
      
      cloudflared
      qemu

      # Aws
      awscli2

      # Kube
      kind      
      kubernetes-helm      
      kubectl
      kubectx
      cilium-cli
      hubble # cilium hubble
      talosctl      
      argocd
      #(krewKubectl.withKrewPlugins (plugins: [
      #      plugins.oidc-login
      #    ]))

      # Terra
      #tenv #tf tooling
      #opentofu
      terraform
      terragrunt
      atmos

      
      ansible
  ];
  home.shellAliases = {
    "k" = "kubectl";
    "terraform" = "tofu";
  };

  programs.k9s.enable = true;
  xdg.configFile."k9s/skin.yml".source = let
    theme = pkgs.fetchFromGitHub {
      owner = "catppuccin";
      repo = "k9s";
      rev = "322598e19a4270298b08dc2765f74795e23a1615";
      sha256 = "GrRCOwCgM8BFhY8TzO3/WDTUnGtqkhvlDWE//ox2GxI=";
    };
  in "${theme}/dist/mocha.yml";
}