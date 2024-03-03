{ inputs, config, pkgs,  lib, ... }:
{
  users.users.carles = {
   isNormalUser = true;
   description = "carles";
   shell = pkgs.bash;   
  };
}