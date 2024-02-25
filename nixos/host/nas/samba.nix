{ inputs, config, pkgs, nixpkgs, lib, ... }:
{
 services.samba = {
    enable = true;
    securityType = "user";
    extraConfig = ''
      workgroup = WORKGROUP
      server string = ${params.hostname}
      netbios name = ${params.hostname}
      security = user
      #use sendfile = yes
      #max protocol = smb2
      guest account = nobody
      map to guest = bad user
    '';
    shares = {
      homes = {
        browsable = "no";
        writable = "yes";
      };
      media = {
        path = "/media/media";
        browsable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
      };
      media2 = {
        path = "/media/media2";
        browsable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
      };
      games = {
        path = "/media/games";
        browsable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
      };
    };
  };
}