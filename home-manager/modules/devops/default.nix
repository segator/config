{ config, pkgs,inputs, ... }:
let
  krewKubectl = inputs.krew2nix.packages."x86_64-linux".kubectl;
in
{  
  home.packages = with pkgs; [
      devbox
      lazydocker
      kind      
      kubernetes-helm      
      kubectl
      awscli2
      tenv #tf tooling
      argocd
      ansible
      #(krewKubectl.withKrewPlugins (plugins: [
      #      plugins.oidc-login
      #    ]))
  ];

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