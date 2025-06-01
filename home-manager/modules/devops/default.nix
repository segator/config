{ lib,config, pkgs,inputs, ... }:
let
  krewKubectl = inputs.krew2nix.packages."x86_64-linux".kubectl;
in
{
  imports = [
    ./aws.nix
    ./oci.nix
    ./cloudflare.nix
    ./hetzner.nix
  ];
  home.packages = with pkgs; [
      devbox
      go-task
      devspace
      gnumake
      gh
      lazydocker
      packer
      cloudflared
      qemu

      # Aws
      awscli2
      eksctl

      # Kube
      kind      
      kubernetes-helm      
      kubectl
      kubectx
      kubeswitch
      kubeseal
      fluxcd
      cilium-cli
      hubble # cilium hubble
      talosctl
      omnictl
      argocd
      argo # argo workflow
      crossplane-cli
      upbound
      vcluster
      

      # Terra
      #tenv #tf tooling
      terraform
      opentofu
      terragrunt
      terramate
      terraspace
      atmos
      pulumi
      pulumiPackages.pulumi-language-go
      pulumiPackages.pulumi-language-nodejs
      nodejs

      
      ansible
  ];
  home.shellAliases = {
    "k" = "kubectl";
    #"terraform" = "tofu";
  };
  # home.sessionPath = [ "$HOME/.krew/bin/" ];
  # I dont know why sessionPath is not working so workarround...
  #programs.bash = lib.mkIf config.programs.bash.enable {
  #  bashrcExtra = ''
  #    export PATH="$PATH:$HOME/.krew/bin/"
  #  '';
  #  #shellAliases = [];
  #};  

  programs.bash.initExtra = lib.mkIf config.programs.bash.enable  ''
    complete -o nospace -C ${pkgs.awscli2}/bin/aws_completer aws
    complete -o nospace -C ${pkgs.terraform}/bin/terraform terraform
    complete -o nospace -C ${pkgs.opentofu}/bin/tofu tofu
    source <(${pkgs.kubectl}/bin/kubectl completion bash)
  '';

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
      "virt" # kubevirt
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