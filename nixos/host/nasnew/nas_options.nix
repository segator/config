{ self, config, lib, pkgs, ... }:
let
    cfg = config.nas;
in
{
    options.nas = {
        shares = lib.mkOption {
            type = with lib.types; attrsOf (submodule {
                options = {
                    path = lib.mkOption {
                        type = str;                            
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
                };
            });
        };
        groups = lib.mkOption {
            type = with lib.types; attrsOf (submodule {
                options = {
                    gid = lib.mkOption {
                        type = int;
                    };
                    members = lib.mkOption {
                        type = (listOf str);
                    };
                };
            });
        };
    };
}