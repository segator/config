{ config, pkgs, ... }:
{


  imports = [
    ./golang.nix
    ./dotnet.nix
    ./java.nix
    ./c.nix
    ./github.nix
    #./python.nix
    ./node.nix
  ];

  home.packages = with pkgs; [
    #jetbrains.gateway
    vscode

  ];
}