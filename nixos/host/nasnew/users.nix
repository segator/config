{ inputs, config, pkgs, nixpkgs, lib, ... }:{ 
    users.users.daga12g = {
        uid = 1000;
        shell = "/run/current-system/sw/bin/nologin";
        #home = "/nas/homes/daga12g";
        createHome = false;  
    };
    users.users.segator = {
        uid = 1001;
        shell = "/run/current-system/sw/bin/nologin";
        #home = "/nas/homes/segator";
        createHome = false;    
    };
    users.users.carles = {
        uid = 1002;
        shell = "/run/current-system/sw/bin/nologin";
        #home = "/nas/homes/carles";
        createHome = true;  
    };
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
}