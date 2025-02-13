{ config, pkgs, ... }:
{


  imports = [
    ./golang.nix
    ./dotnet.nix
    ./java.nix
    ./c.nix
    #./python.nix
    ./node.nix
  ];

  home.packages = with pkgs; [
    #jetbrains.gateway
    vscode

  ];
}