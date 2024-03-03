{ config, pkgs, lib, ... }:
let
  ssh_user_pubkey="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID5vRrC3yycYEP9GoKk4nm9iTf9aFMb0pAyKbp5rcEkW segator";
  authorized_keys = [ 
    ssh_user_pubkey
    ];
in
{
  imports = [
    ../../modules/shell {}
    ../../modules/sops
  ];
  
  home.username = "segator";
  home.homeDirectory = lib.mkDefault "/home/segator";

  home.stateVersion = "23.05"; 

  programs.home-manager.enable = true;

  home.file.".ssh/authorized_keys" = {
    text=''
  ${ssh_user_pubkey}
  '';
  };

  home.file.".ssh/id_ed25519.pub" = {
    text=''
    ${ssh_user_pubkey}
    '';
  };
}