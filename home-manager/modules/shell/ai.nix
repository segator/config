
{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
        fabric-ai
    ];

  #  programs.bash = lib.mkIf config.programs.bash.enable {

  #   shellAliases = 
  #     { 
        
  #     }  
  # };  
}


