{ inputs, config, pkgs, nixpkgs, lib, ... }:
{
 services.samba-wsdd = {
  enable = true;
  openFirewall = true;
 };
 services.samba = {
    #package = pkgs.samba4Full;
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

        "veto files" = "/.apdisk/.DS_Store/.TemporaryItems/.Trashes/desktop.ini/ehthumbs.db/Network Trash Folder/Temporary Items/Thumbs.db/";
        "delete veto files" = "yes";
      };

      photo = {
        comment = "photo";
        path = "/nas/photo";
        browseable = "yes";
        "guest ok" = "no";
        writeable = "yes";
        "valid users" = "@isaacaina";
        "read only" = "no";
        "create mask" = "0770";
        "directory mask" = "0770";
        "vfs objects" = "shadow_copy2";

        "veto files" = "/.apdisk/.DS_Store/.TemporaryItems/.Trashes/desktop.ini/ehthumbs.db/Network Trash Folder/Temporary Items/Thumbs.db/";
        "delete veto files" = "yes";
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

        "veto files" = "/.apdisk/.DS_Store/.TemporaryItems/.Trashes/desktop.ini/ehthumbs.db/Network Trash Folder/Temporary Items/Thumbs.db/";
        "delete veto files" = "yes";
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

        "veto files" = "/.apdisk/.DS_Store/.TemporaryItems/.Trashes/desktop.ini/ehthumbs.db/Network Trash Folder/Temporary Items/Thumbs.db/";
        "delete veto files" = "yes";
      };

      crbmc = {
        comment = "CRBMC";
        path = "/nas/crbmc";
        browseable = "yes";
        "guest ok" = "no";
        writeable = "yes";
        "valid users" = "@aymerich";
        "read only" = "no";
        "create mask" = "0770";
        "directory mask" = "0770";
        "vfs objects" = "shadow_copy2";

        "veto files" = "/.apdisk/.DS_Store/.TemporaryItems/.Trashes/desktop.ini/ehthumbs.db/Network Trash Folder/Temporary Items/Thumbs.db/";
        "delete veto files" = "yes";
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

        "veto files" = "/.apdisk/.DS_Store/.TemporaryItems/.Trashes/desktop.ini/ehthumbs.db/Network Trash Folder/Temporary Items/Thumbs.db/";
        "delete veto files" = "yes";
      };
    };
  };

  services.avahi = {
    publish.enable = true;
    publish.userServices = true;
    # ^^ Needed to allow samba to automatically register mDNS records (without the need for an `extraServiceFile`
    nssmdns4 = true;
    # ^^ Not one hundred percent sure if this is needed- if it aint broke, don't fix it
    enable = true;
    openFirewall = true;
  };
}