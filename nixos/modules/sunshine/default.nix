{ inputs, config, pkgs,  lib, ... }:
{
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
    
  };

#   security.wrappers.sunshine = {
#         owner = "root";
#         group = "root";
#         capabilities = "cap_sys_admin+p";
#         source = "${pkgs.sunshine}/bin/sunshine";
#  };
#  services.avahi.publish.enable = true;
# services.avahi.publish.userServices = true;
}