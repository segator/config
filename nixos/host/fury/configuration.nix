{ inputs, config, pkgs, nixpkgs, lib, ... }:
{
  imports =
    [
      inputs.nixos-hardware.nixosModules.common-cpu-amd
      inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
      ./hardware-configuration.nix
      ../../modules/boot
      ../../modules/common.nix
      ../../modules/nix-sops
      ../../modules/hyprland
      #./syncthing.nix
      ../../modules/nix
      ../../modules/gnome
      ../../modules/vpn
      ../../modules/roche_certs   
      ../../modules/fwupd  
      ../../modules/sshd
      ../../modules/virtualisation
      ../../modules/gaming

      ../../users/aymerici
      ../../users/segator
    ];

  # Bootloade
  boot.extraModprobeConfig = ''
  options kvm_amd nested=1
  options nvidia NVreg_UsePageAttributeTable=1
  options nvidia NVreg_RegistryDwords="OverrideMaxPerf=0x1"
  options nvidia NVreg_PreserveVideoMemoryAllocations=1
  options nvidia NVreg_TemporaryFilePath=/var/tmp
  '';
  boot.kernelParams = [
        "nouveau.modeset=0"
  ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules = [ 
    "kvm-amd" 
    "nvidia"
    "nvidia_modeset"
    "nvidia_uvm"
    "nvidia_drm"
    ];
  boot.supportedFilesystems = [ "ntfs" ];
  boot.binfmt.emulatedSystems = [
    "aarch64-linux"  
  ];
  networking.hostName = "fury"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Madrid";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

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

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
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




  services.dbus.enable = true;


  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
#    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  environment.variables.VDPAU_DRIVER = "va_gl";
  environment.variables.LIBVA_DRIVER_NAME = "nvidia";

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true; 
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
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

  sops.secrets.testsecret = {
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?


}
