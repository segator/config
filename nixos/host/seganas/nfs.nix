{ inputs, config, pkgs, nixpkgs, lib, ... }:
{


  fileSystems."/nfs/nas" = {
    device = "/nas";
    options = [ "bind" ];
  };                                                                                            
  services.nfs.server.enable = true;
  services.nfs.server.exports = ''
    /nfs/nas 192.168.0.178(rw,no_subtree_check)
  '';      
       
}