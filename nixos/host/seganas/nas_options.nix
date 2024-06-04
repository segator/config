{ self, config, lib, pkgs, ... }:
let
    cfg = config.nas;
    groupType = with lib.types; attrsOf (submodule {
                options = {
                    gid = lib.mkOption {
                        type = int;
                    };
                    members = lib.mkOption {
                        type = (listOf str);
                    };
                };
            });
in
{
    options.nas = {
        shares = lib.mkOption {
            type = with lib.types; attrsOf (submodule {
                options = {
                    path = lib.mkOption {
                        type = str;                            
                    };
                    backup = lib.mkOption {
                        type = bool;
                        default = false;
                    };
                    isHome = lib.mkOption {
                        type = bool;
                        default = false;
                    };
                    groups = lib.mkOption {
                        type = (listOf str);
                    };
                };
            });
        }; 
        users = lib.mkOption {
            type = with lib.types; attrsOf (submodule {
                options = {
                    uid = lib.mkOption {
                        type = int;
                    };
                    passwordFile = lib.mkOption {
                        type = str;
                    };
                };
            });
        };
        groups = lib.mkOption {
            type = groupType;
        };

        backup = lib.mkOption {
            type =  with lib.types; (submodule {
                options = {
                    sourceDirectories = lib.mkOption {
                        type = (listOf str);
                        default = [];
                        description = "List of directories to be backed up.";
                    };                    
                };
            }); 
        };

    };
    config = {
        nas = {
            groups = lib.mkMerge [
            {
                nasusers = {
                    gid = 1999;
                    members = (builtins.attrNames config.nas.users);
                };  
            }
            # We create groups per each user
            (lib.mapAttrs(name: value: 
            {
                gid = value.uid;
                members = [name];
            }) config.nas.users)
            ];

            backup.sourceDirectories = lib.mkMerge [ (map (share: share.path) (lib.filter (share: share.backup) (builtins.attrValues config.nas.shares)))];
        };
    };
}