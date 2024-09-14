{ inputs, config, pkgs, nixpkgs, lib, ... }:
{
  imports =
    [
      inputs.nixos-hardware.nixosModules.dell-xps-15-9520
      inputs.nixos-hardware.nixosModules.common-gpu-nvidia-disable
      #inputs.nixos-hardware.nixosModules.dell-xps-15-9520-nvidia
      ./hardware-configuration.nix
      ../../modules/boot
      ../../modules/common.nix
      ../../modules/nix-sops
      ../../modules/battery
      ../../modules/displaylink
      ../../modules/nix
      ../../modules/wifi
      ../../modules/vpn
      ../../modules/roche_certs  
      ../../modules/gnome
      #../../modules/hyprland
      ../../modules/virtualisation
      #../../modules/fprintd
      ../../modules/sshd
      ../../modules/fwupd
      ../../modules/logind
      ../../modules/weylus
      ../../modules/sunshine
      ../../users/aymerici
      
    ];


  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;

  #hardware.nvidia = {
  #  modesetting.enable = true;
  #  powerManagement.enable = true;
#    open = true;
#    nvidiaSettings = true;
#    package = config.boot.kernelPackages.nvidiaPackages.stable;
#    prime.offload = {
#			enable = true;
#			enableOffloadCmd = true;
#		};
#    powerManagement.finegrained = true;
#  };

  #boot.kernelParams = [ "iommu=off" "intel_iommu=off"];
  #boot.blacklistedKernelModules = [ "intel_lpss_pci"];
  #boot.extraModprobeConfig = ''
  #  options snd_ha_intel power_save=1
  #  options iwlwifi power_save=1
  #'';
  boot.kernel.sysctl = {
    #"vm.laptop_mode" = 5;
    #"kernel.nmi_watchdog" = 0;
    #"vm.dirty_writeback_centisecs" = 6000;
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;
  # boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.linuxPackages_latest.override {
  #   argsOverride = rec {
  #     src = pkgs.fetchFromGithub {
  #         owner = "torvalds";
  #         repo = "linux";
  #         rev = "master";
  #         sha256 = "0rs9bxxrw4wscf4a8yl776a8g880m5gcm75q06yx2cn3lw2b7v22";
  #       };

  #     version = "6.9-rc3";
  #     modDirVersion = "6.9-rc3";
  #     };
  # });
  networking.hostName = "xps15";

# boot.kernelPatches = [
#  {
#    name = "mfd-intel-lpss-v4";
#    patch = ./mfd-intel-lpss-v4.patch;
#  }
# ];

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Madrid";

  # Select internationalisation properties.
  i18n.defaultLocale = "es_ES.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "es_ES.UTF-8";
    LC_IDENTIFICATION = "es_ES.UTF-8";
    LC_MEASUREMENT = "es_ES.UTF-8";
    LC_MONETARY = "es_ES.UTF-8";
    LC_NAME = "es_ES.UTF-8";
    LC_NUMERIC = "es_ES.UTF-8";
    LC_PAPER = "es_ES.UTF-8";
    LC_TELEPHONE = "es_ES.UTF-8";
    LC_TIME = "es_ES.UTF-8";
  };
  
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;  


  environment.sessionVariables = rec { 
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND= "1";
    RTC_USE_PIPEWIRE= "true";
  };

  
  # Enable Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = false;
  services.blueman.enable = true;
  
  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "es";
    xkb.variant = "";
  };

  # Configure console keymap
  console.keyMap = "es";

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
  services.printing = 
  {
    enable = true;
    drivers = [pkgs.hplipWithPlugin ];
  };
  # Scanner
  hardware.sane = {
    enable = true;
    extraBackends = [pkgs.hplipWithPlugin ];
  };
  nixpkgs.config.packageOverrides = pkgs: {
    xsaneGimp = pkgs.xsane.override { gimpSupport = true; };
  };
  # Enable sound with pipewire.
  #sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };



  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
  ];

  environment.systemPackages = with pkgs; [
    gimp
    home-manager
    git
    
    fd
    jq
    fzf
    bat
    tmux
    htop
    btop
    iotop
    nload
    wget
    unzip
    glibc
    mesa-demos      
    lm_sensors
    kitty
    virt-manager
    neofetch

    moonlight-qt
  ];


  services.dbus.enable = true;

  hardware.graphics = {
    enable32Bit = true;
    enable = true;
    extraPackages = with pkgs; [
      libvdpau-va-gl
    ];
  };


  networking.extraHosts =
  ''
  192.168.49.2 idp.edge.local
  192.168.49.2 iam.edge.local
  192.168.49.2 iam-console.edge.local
  192.168.49.2 iam-client.edge.local
  10.21.81.122 idp.navify-anywhere.labnet.roche.com
  10.21.81.122 iam.navify-anywhere.labnet.roche.com
  10.21.81.122 console.navify-anywhere.labnet.roche.com
  '';

  networking.firewall.enable = true;
  system.stateVersion = "23.11"; # Did you read the comment?

}
