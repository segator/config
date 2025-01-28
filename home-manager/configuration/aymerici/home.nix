{ config, pkgs, lib, ... }:
let
  ssh_pubkey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCSqoWu0J6MkjN5F6FWt3rho4kfFv9/9/4RluZC/Ot2n6cQs5wJ5EsEkwQ54noXhky2Zqhhtw28u0ZT9aGGJz+0Gr/6USsyi7xp7u0zmGdjmNx6SO+9NHSOUg4r38zr8aAJSnJHbhz0blKuASnQi5yNp4eYr/WxUs+L4tFwfiktb6cmKQ3S6AJiduFBEx6mySOPkGDXG+Vxz9UfYBZwuGUI6w9jjUoteo4NA3nr8rYTh1O3mdvLsMkokpzqbNPF9b9CY8z6qFtyiBqaz6ob+xe4AGIxUmng7dDGJiUAoYPALpScJSeQf3Kqa/RGkFqZO66tROm1kDZB9loOId/E9Q9ml19cguEdcPPo6QFkTj1gl3Q/I0JZ6oqtQmctPEEW8hw/Ggi4qCZAiz1JmXp4FnVl4JH/MWq265GcnYvJNs1DbuydAONJ1KbnD4MW8yor41or5+mvLbgasWgwzUmlRGZFrqojIINE3q5eQ0XvxR+xxODFLvfjWjZBoRqMayVU/lU= aymerici";
  ssh_user_pubkey="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID5vRrC3yycYEP9GoKk4nm9iTf9aFMb0pAyKbp5rcEkW segator";
  authorized_keys = [ 
    ssh_pubkey
    ssh_user_pubkey
    ];
in
{
  imports = [
    ../../modules/shell
    ../../modules/sops
  ];
  
  home.username = "aymerici";
  home.homeDirectory = if pkgs.system == "aarch64-darwin"
                then "/Users/aymerici"
                else "/home/aymerici";

  home.stateVersion = "23.05"; 

  programs.home-manager.enable = true;


  home.file.".ssh/authorized_keys" = {
    text=''
  ${ssh_pubkey}
  ${ssh_user_pubkey}
  '';
  };

  home.file.".ssh/id_ed25519.pub" = {
    text=''
    ${ssh_user_pubkey}
    '';
  };
  home.file.".ssh/id_rsa_roche.pub" = {
    text=''
    ${ssh_pubkey}
    '';
  };
}
