{ inputs, config, pkgs, lib, ... }:

let
  usersConfig = {
    daga12g = { uid = 1000; };
    segator = { uid = 1001; };
    carles = { uid = 1002; };
  };



  groupsConfig = {  
    nasservices = {
      gid = 2000;
      members = (builtins.attrNames usersConfig) ++ lib.optionals config.services.nextcloud.enable [ "nextcloud" ];
    };
    isaacaina = {
      gid = 1100;
      members = [
        "daga12g"
        "segator"
      ];
    };
    aymerich = {
      gid = 1101;
      members = [
        "daga12g"
        "segator"
        "carles"
      ];
    };
  };

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