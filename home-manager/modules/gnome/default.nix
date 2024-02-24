{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    gnome.gnome-power-manager
    gnomeExtensions.user-themes
    gnomeExtensions.tray-icons-reloaded
    gnomeExtensions.vitals
    gnomeExtensions.dash-to-panel
    gnomeExtensions.sound-output-device-chooser
    gnomeExtensions.space-bar
  ];

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      show-battery-percentage = true;
      color-scheme = "prefer-dark";
      gtk-theme = "Catppuccin-Macchiato-Standard-Pink-Dark";
      cursor-theme = "Bibata-Modern-Ice";
      icon-theme = "Fluent-dark";
    };
    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-type = "nothing";
    };

    "org/gnome/shell/extensions/vitals" = {
        show-battery = true;
        hide-zeros = true;
        position-in-panel = 2;
        hot-sensors = [
          "_processor_usage_"
          "_memory_usage_"
          "_temperature_processor_0_"
          "__network-rx_max__"
          "__network-tx_max__"
          "_battery_rate_"
          "_battery_time_left_"
        ];
    };

#    "/org/gnome/shell/keybindings".toggle-message-tray = [ ""];
    "org/gnome/desktop/wm/keybindings" = {
        always-on-top = "['<ctrl><Super>v']";
        activate-window-menu = "disabled";
        toggle-message-tray = "disabled";
        close = ["<Super>q"];
        maximize = "disabled";
        minimize = ["<Super>comma"];
        move-to-monitor-down = "disabled";
        move-to-monitor-left = "disabled";
        move-to-monitor-right = "disabled";
        move-to-monitor-up = "disabled";
        move-to-workspace-down = "disabled";
        move-to-workspace-up = "disabled";
        toggle-maximized = ["<Super>m"];
        unmaximize = "disabled";
      };
      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
        ];
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        name = "kitty super";
        command = "kitty -e tmux";
        binding = "<Super>Return";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
        name = "rofi-rbw";
        command = "rofi-rbw --action copy";
        binding = "<Ctrl><Super>s";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
        name = "rofi launcher";
        command = "rofi -theme nord -show run -display-run 'run: '";
        binding = "<Super>space";
      };
    "org/gnome/shell/extensions/user-theme".name = "Catppuccin-Macchiato-Standard-Pink-Dark";
#    "org/gnome/shell/extensions/gtk-theme".name = "Catppuccin-Macchiato-Standard-Blue-Dark";
    "org/gnome/shell" = {
      disable-user-extensions = false;

      # `gnome-extensions list` for a list
      enabled-extensions = [
        "user-theme@gnome-shell-extensions.gcampax.github.com"
#        "trayIconsReloaded@selfmade.pl"
        "Vitals@CoreCoding.com"
#        "dash-to-panel@jderose9.github.com"
#        "sound-output-device-chooser@kgshank.net"
#        "space-bar@luchrioh"
      ];

    };
  };
 

  gtk = {
    enable = true;
    theme = {
      name = "Catppuccin-Macchiato-Standard-Pink-Dark";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "pink" ];
        size = "standard";
        tweaks = [ "normal" "rimless" ];
        variant = "macchiato";
      };
    };
    cursorTheme = {
      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
    };

    iconTheme = {
      name = "Fluent-dark";
      package = pkgs.fluent-icon-theme;
    };
  };
  home.sessionVariables.GTK_THEME = "Catppuccin-Mocha-Standard-Pink-Dark";
  qt = {
    enable = true;
    platformTheme = "gtk";
    style.name = "Catppuccin-Mocha-Standard-Pink-Dark"; # adwaita-gtk
  };

}



