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
  ];
  home.packages = with pkgs; [
    neofetch
  ];
}

      