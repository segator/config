{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    (jetbrains.plugins.addPlugins jetbrains.goland [ "github-copilot" ])
    go_1_20
    gcc  
  ];
}