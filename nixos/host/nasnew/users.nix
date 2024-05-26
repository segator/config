


{ inputs, config, pkgs, lib, ... }:

let
  usersConfig = config.nas.users;


  groupsConfig = {  
    nasservices = {
      gid = 2000;
      members = (builtins.attrNames usersConfig) ++ lib.optionals config.services.nextcloud.enable [ "nextcloud" ];
    };
  } // config.nas.groups;
in
{
  users.users = lib.mapAttrs (username: user:      
    {
        uid = user.uid;
        shell = "/run/current-system/sw/bin/nologin";
        createHome = false;
        isNormalUser = true;
    }) usersConfig;

  users.groups = (lib.mapAttrs ( username: user:    
  {
    gid = user.uid;
    members = [ "${username}" ];        
  }) usersConfig)
  //
  groupsConfig;

}