{ lib,config, pkgs,inputs, ... }:
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
      crossplane-cli
      upbound

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
  # home.sessionPath = [ "$HOME/.krew/bin/" ];
  # I dont know why sessionPath is not working so workarround...
  programs.bash = lib.mkIf config.programs.bash.enable {
    bashrcExtra = ''
      export PATH="$PATH:$HOME/.krew/bin/"
    '';
    #shellAliases = [];
  };  



  programs.krewfile = {
    enable = true;
    upgrade = true;
    krewPackage = pkgs.krew;
    #indexes = { foo = "https://github.com/nilic/kubectl-netshoot.git" };
    plugins = [
      #"foo/some-package"
      "explore" # nice way to see resources
      "modify-secret" # allow to modify existing secrets
      "neat" # extract installed objects and clean them up to yam
      "oidc-login" # kube oidc
      "pv-migrate" # migrate between pv
      "stern" # tail multiple pod logs
      "ice" # monitor and optimize container resources
      "ktop" # like top
      "open-svc" # like port-forward but easier
      "resource-capacity" # see cpu/mem usage of pods
      "linstor" # linstor plugin
      "outdated" # print outdated images
    ];
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