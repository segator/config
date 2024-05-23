{ self, config, lib, pkgs, ... }:
let
    cfg = config.nas;
in
{
    options = {
        nas = {
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
        };
    };
}