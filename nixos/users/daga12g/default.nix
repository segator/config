{ inputs, config, pkgs,  lib, ... }:
{
  users.users.daga12g = {
   isNormalUser = true;
   description = "daga";
   shell = pkgs.bash;
  };
}