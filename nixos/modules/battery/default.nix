{ inputs, config, pkgs,  lib, ... }:
{
    #services.system76-scheduler.settings.cfsProfiles.enable = true;
    #hardware.system76.enableAll = true;
    # TODO what I should finally use?
    services.auto-cpufreq = {
        enable = false;
        settings = {
            battery = {
                governor = "powersave";
                turbo = "never";
            };
            charger = {
                governor = "performance";
                turbo = "auto";
            };
        };
    };


    # Enable TLP (better than gnomes internal power manager)
    services.tlp = {
      enable = false;
      settings = {
        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 0;
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 20;

       START_CHARGE_THRESH_BAT0 = 40; # 40 and bellow it starts to charge
       STOP_CHARGE_THRESH_BAT0 = 80; # 80 and above it stops charging
      };

      
    };

    services.power-profiles-daemon.enable = true;

    # Enable powertop
    powerManagement.powertop.enable = true;

    # TODO condition this to only intel
    services.thermald.enable = true;
}