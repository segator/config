{ config, pkgs, lib, ... }:
{
services = {
  syncthing = {
    enable = true;
    user = "aymerici";
    dataDir = "/home/aymerici/Documents";
    configDir = "/home/aymerici/.config/syncthing";
    overrideDevices = true;     # overrides any devices added or deleted through the WebUI
    overrideFolders = true;     # overrides any folders added or deleted through the WebUI
    settings = {
      devices = {
        "NAS" = { id = "GPFT5D2-V7BYNUB-QYJRJ6J-YRXYOGZ-5SDTNCI-AZ64X2A-NURJSPQ-5IH6TQB"; };
        "XPS15" = { id = "GPFT5D2-V7BYNUB-QYJRJ6J-YRXYOGZ-5SDTNCI-AZ64X2A-NURJSPQ-5IH6TQ6"; };
      };
      
      folders = {
        "Documents" = {        # Name of folder in Syncthing, also the folder ID
          path = "/home/aymerici/Documents";    # Which folder to add to Syncthing
          devices = [ "NAS" "XPS15" ];      # Which devices to share the folder with
        };
      };
    };
    

  };
};
}

