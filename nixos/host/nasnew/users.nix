


{ inputs, config, pkgs, lib, ... }:

let
  usersConfig = config.nas.users;


  groupsConfig = {  
    nasservices = {
      gid = 2000;
      members = (builtins.attrNames usersConfig) ++ lib.optionals config.services.nextcloud.enable [ "nextcloud" ];
    };
    nasusers = {
      gid = 1999;
      members = (builtins.attrNames usersConfig);
    };
  } // config.nas.groups;
in
{

  sops.secrets = builtins.listToAttrs (
    builtins.map (key: 
      {name = "${key}_password"; value = {};}) (builtins.attrNames usersConfig
    )
  );
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