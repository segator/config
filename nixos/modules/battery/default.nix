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


    # script to know battery consumption in idle
    environment.etc."systemd/system-sleep/batenergy.sh".source =
        pkgs.writeShellScript "batenergy.sh" ''
        FILE=./batenergy.dat

        state=$1
        sleep_type=$2

        now=`date +'%s'`

        read energy_now < /sys/class/power_supply/BAT0/charge_now #μWh
        read energy_full < /sys/class/power_supply/BAT0/charge_full # μWh
        read online < /sys/class/power_supply/AC/online


        (($online)) && echo "Currently on mains."
        ((! $online)) && echo "Currently on battery."

        case $state in
        "pre")
            echo "Saving time and battery energy before sleeping ($sleep_type)."
            echo $now > $FILE
            echo $energy_now >> $FILE
            ;;
        "post")
            exec 3<>$FILE
            read prev <&3
            read energy_prev <&3
            rm $FILE
            time_diff=$(($now - $prev)) # seconds
            days=$(($time_diff / (3600*24)))
            hours=$(($time_diff % (3600*24) / 3600))
            minutes=$(($time_diff % 3600 / 60))
            echo "Duration of $days days $hours hours $minutes minutes sleeping ($sleep_type)."
            energy_diff=$((($energy_now - $energy_prev) / 1000)) # mWh
            avg_rate=$(($energy_diff * 3600 / $time_diff)) # mW
            energy_diff_pct=$(${pkgs.bc}/bin/bc <<< "scale=1;$energy_diff * 100 / ($energy_full / 1000)") # %
            avg_rate_pct=$(${pkgs.bc}/bin/bc <<< "scale=2;$avg_rate * 100 / ($energy_full / 1000)") # %/h
            echo "Battery energy change of $energy_diff_pct % ($energy_diff mWh) at an average rate of $avg_rate_pct %/h ($avg_rate mW)."
            ;;
        esac
    '';
}