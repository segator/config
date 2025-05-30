{ inputs, config, pkgs, nixpkgs, lib, ... }:
let
  smbpasswdCommand = username: _: ''
    smbPassword=$(${pkgs.busybox}/bin/cat "${config.sops.secrets."${username}_password".path}")
    ${pkgs.busybox}/bin/echo -e "$smbPassword\n$smbPassword\n" | ${pkgs.samba}/bin/smbpasswd -a -s ${username}
  '';
in
{
 services.samba-wsdd = {
  enable = true;
  openFirewall = true;
 };
 services.samba = {
    #package = pkgs.samba4Full;
    enable = true;
    openFirewall = true;    
    settings = {
      global = {
      "workgroup" = "NAS";
      "log file" = "/var/log/samba/log.%m";
      "max log size" = "1000";
      "logging" = "file";
      "panic action" = "/usr/share/samba/panic-action %d";
      "server role" = "standalone server";
      "obey pam restrictions" = "yes";
      "unix password sync" = "yes";    
      "security" = "user";        
      "map to guest" = "bad user";
      "passwd chat" = "*Enter\snew\s*\spassword:* %n\n *Retype\snew\s*\spassword:* %n\n *password\supdated\ssuccessfully* .";
      "pam password change" = "yes";
      "usershare allow guests" = "no";
      "shadow:localtime" = "no";
      "shadow:delimiter" = "-";
      "shadow:snapprefix" = "^scheduled";
      "shadow:format" = "-%Y-%m-%d-%H_%M_%S_UTC";
      "shadow:sort" = "desc";
      "shadow:snapdir" = ".snap";
      "vfs objects" = "catia acl_xattr shadow_copy2";
      };
    } // lib.mapAttrs (shareName: shareConfig: {
      comment = shareName;
      path = if shareConfig.isHome then shareConfig.path + "/%S" else shareConfig.path; 
      browseable = "yes";
      "guest ok" = "no";
      writeable = "yes";
      "read only" = "no";
      "create mask" = "0660";
      "directory mask" = "0770";
      "vfs objects" = "shadow_copy2";
      "veto files" = "/.apdisk/.DS_Store/.TemporaryItems/.Trashes/desktop.ini/ehthumbs.db/Network Trash Folder/Temporary Items/Thumbs.db/";
      "delete veto files" = "yes";
      "valid users" = if shareConfig.isHome then "%S" else "${lib.concatStringsSep " " (map (groupName: "@${groupName}") shareConfig.groups)}";
      "force group" = if shareConfig.isHome then "%S" else "${lib.concatStringsSep " " shareConfig.groups}";
      }
    ) config.nas.shares;
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

  # Configure smb users  after samba is running
  systemd.services.samba-user-setup = {
    enable = true;
    description = "Configure samba users";
    script = ''
    ${lib.concatStringsSep "\n" (lib.mapAttrsToList smbpasswdCommand config.nas.users)}
    '';

    serviceConfig.Type = "oneshot";
    requires = [ "samba-smbd.service" ];
    restartIfChanged = true;
    wantedBy = [ "samba-smbd.service" ];
    after = [ "samba-smbd.service" ];
  };

}