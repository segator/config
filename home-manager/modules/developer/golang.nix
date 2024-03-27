{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    (jetbrains.plugins.addPlugins jetbrains.goland [ "github-copilot" ])
    go
    gcc  
  ];
}