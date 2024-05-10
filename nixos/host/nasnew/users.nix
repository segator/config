{ inputs, config, pkgs, lib, ... }:

let
  usersConfig = {
    daga12g = { uid = 1000; };
    segator = { uid = 1001; };
    carles = { uid = 1002; };
  };

  groupsConfig = {   
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



  smbpasswdCommand = username: user: ''
    smbPassword=$(cat "${config.sops.secrets."${username}_password".path}")
    echo -e "$smbPassword\n$smbPassword\n" | /run/current-system/sw/bin/smbpasswd -a -s ${username}
  '';
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
        shell = lib.mkForce "/run/current-system/sw/bin/nologin";
        createHome = false;
    }) usersConfig;

  users.groups = (lib.mapAttrs ( username: user:    
  {
    gid = user.uid;
    members = [ "${username}" ];        
  }) usersConfig)
  //
  groupsConfig;

  system.activationScripts.samba_user_create = ''
    ${lib.concatStringsSep "\n" (lib.mapAttrsToList smbpasswdCommand usersConfig)}
  '';
}