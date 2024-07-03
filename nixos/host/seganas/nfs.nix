{ inputs, config, pkgs, nixpkgs, lib, ... }:
{


  fileSystems."/nfs/nas" = {
    device = "/nas";
    options = [ "bind" ];
  };                                                                                            
  services.nfs.server = {
  enable = true;
  lockdPort = 4001;
  mountdPort = 4002;
  statdPort = 4000;
  #all_squash
  exports = ''
    /nfs 192.168.0.250(no_subtree_check,no_root_squash,no_all_squash,async,rw,insecure,fsid=root) 192.168.0.252(no_subtree_check,no_root_squash,no_all_squash,async,rw,insecure,fsid=root) 192.168.0.254(no_subtree_check,no_root_squash,no_all_squash,async,rw,insecure,fsid=root) 192.168.0.249(no_subtree_check,no_root_squash,no_all_squash,async,rw,insecure,fsid=root)
    /nfs/nas 192.168.0.250(no_subtree_check,no_root_squash,no_all_squash,async,rw,insecure) 192.168.0.252(no_subtree_check,no_root_squash,no_all_squash,async,rw,insecure) 192.168.0.254(no_subtree_check,no_root_squash,no_all_squash,async,rw,insecure) 192.168.0.249(no_subtree_check,no_root_squash,no_all_squash,async,rw,insecure)
 
  ''; 
  };

  services.nfs.settings.nfsd={
    # UDP="on";
    # TCP="on";
    enableTCPOptions = true;
    enableUDPOptions = true;
    # rdma = "true"; # Remote Direct Memory Access
    vers3 = "false";
    vers4 = "true";
    "vers4.0" = "false";
    "vers4.1" = "false";
    "vers4.2" = "true";
  };
  services.rpcbind.enable = true;
networking.firewall.allowedTCPPorts = [
  111     # RPC Portmapper
  2049    # NFS
  4000    # NFS Statd
  4001    # NFS Lockd
  4002    # NFS Mountd
  20048   # NFSv4
];
       
}