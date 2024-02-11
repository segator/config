{ config, pkgs, ... }:
{


  imports = [
    ./golang.nix
    ./dotnet.nix
    ./java.nix
    ./c.nix
  ];

  home.packages = with pkgs; [
    jetbrains.gateway
    vscode

    #Build tools
    gnumake
    devbox

    gh
  ];
}