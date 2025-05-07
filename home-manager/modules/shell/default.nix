{ config, pkgs, ... }:
{

  imports = [
    ./ssh.nix
    ./git.nix
    ./direnv.nix
    ./lsd.nix
    ./kitty.nix
    ./fish.nix
    ./bash.nix
    ./starship.nix
    ./tmux.nix
    ./ai.nix
    ./mise.nix
  ];
  home.packages = with pkgs; [
    htop
    neofetch    

    yq
    jq
    dig
  ];
  programs.vim.enable = true;
}