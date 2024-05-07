{ inputs, config, pkgs, lib, ... }:

let
  usersConfig = {
    daga12g = { uid = 1000; };
    segator = { uid = 1001; };
    carles = { uid = 1002; };
  };

   enableSecret = username: 
   {
     "${username}_password" = { };
   };
  sopsSecrets = builtins.map  (username:
    {
        "${username}_password" = { };
    }) (builtins.attrNames usersConfig);
  smbpasswdCommand = username: ''
    smbPassword=$(cat "${config.sops.secrets."${username}_password".path}")
    echo -e "$smbPassword\n$smbPassword\n" | /run/current-system/sw/bin/smbpasswd -a -s ${username}
  '';
in
{

  sops.secrets = builtins.listToAttrs sopsSecrets;
  users.users = lib.mapAttrs (username: userConfig: 
    userConfig // 
    {
        shell = lib.mkForce "/run/current-system/sw/bin/nologin";
        createHome = false;
    }) usersConfig;

  users.groups = {
    segator = {
      gid = 1001;
      members = [ "segator" ];
    };
    daga12g = {
      gid = 1000;
      members = [ "daga12g" ];
    };
    carles = {
      gid = 1002;
      members = [ "carles" ];
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

  system.activationScripts.samba_user_create = ''
    ${lib.concatStringsSep "\n" (lib.mapAttrsToList smbpasswdCommand usersConfig)}
  '';
}