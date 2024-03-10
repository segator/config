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
      log file = /var/log/samba/log.%m
      max log size = 1000
      logging = file
      panic action = /usr/share/samba/panic-action %d
      server role = standalone server
      obey pam restrictions = yes
      unix password sync = yes            
      map to guest = bad user
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
        "writeable" = "yes";
        "valid users" = "%S";
        "read only" = "no";                                                                                              
        "create mask" = "0700";
        "directory mask" = "0700";                                                                                                        
        "vfs objects" = "shadow_copy2";  
      };

      isaacaina = {
        comment = "Isaacaina";
        path = "/nas/isaacaina";
        browseable = "yes";
        "guest ok" = "no";
        writeable = "yes";
        "valid users" = "@isaacaina";
        "read only" = "no";
        "create mask" = "0770";
        "directory mask" = "0770";
        "vfs objects" = "shadow_copy2";
      };

      multimedia = {
        comment = "Multimedia";
        path = "/nas/multimedia";
        browseable = "yes";
        "guest ok" = "no";
        writeable = "yes";
        "valid users" = "@aymerich";
        "read only" = "no";
        "create mask" = "0770";
        "directory mask" = "0770";
        "vfs objects" = "shadow_copy2";
      };

      software = {
        comment = "Software";
        path = "/nas/software";
        browseable = "yes";
        "guest ok" = "no";
        writeable = "yes";
        "valid users" = "@aymerich";
        "read only" = "no";
        "create mask" = "0770";
        "directory mask" = "0770";
        "vfs objects" = "shadow_copy2";
      };

      downloads = {
        comment = "Downloads";
        path = "/nas/downloads";
        browseable = "yes";
        "guest ok" = "no";
        writeable = "yes";
        "valid users" = "@aymerich";
        "read only" = "no";
        "create mask" = "0770";
        "directory mask" = "0770";
        "vfs objects" = "shadow_copy2";
      };
    };
  };
}