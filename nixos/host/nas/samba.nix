{ inputs, config, pkgs, nixpkgs, lib, ... }:
{
 services.samba-wsdd = {
  enable = true;
  openFirewall = true;
 };
 services.samba = {
    enable = true;
    openFirewall = true;
    securityType = "user";
    extraConfig = ''
      workgroup = NAS
      obey pam restrictions = yes
      unix password sync = yes            
      map to guest = bad user
      passwd program = ${pkgs.busybox}/bin/passwd %u
      passwd chat = *Enter\snew\s*\spassword:* %n\n *Retype\snew\s*\spassword:* %n\n *password\supdated\ssuccessfully* .
      pam password change = yes
      usershare allow guests = no
      shadow:localtime = no
      shadow:delimiter = _
      shadow:snapprefix = ^autosnap
      shadow:format = _%Y-%m-%d_%H:%M:%S
      shadow:sort = desc
      shadow:snapdir = .zfs/snapshot
      vfs objects = catia acl_xattr
    '';
    shares = {
      homes = {
        comment = "Home Directories";                                                                                                    
        path = "/nas/homes/%S";
        browseable = "no";
        "guest ok" = "no";
        "writeable" = "no";
        "valid users" = "%S";
        "read only" = "no";                                                                                              
        "create mask" = "0700";
        "directory mask" = "0700";                                                                                                        
        "vfs objects" = "shadow_copy2";  
      };
    };
  };
}