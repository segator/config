{ inputs, config, pkgs,  lib, ... }:
{
  imports = [
    ./nix-sops
    ./boot
    #./fhs.nix
  ];
  environment.systemPackages = with pkgs; [
    # Home
    home-manager

    # Core
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

    # Power
    powertop     
    lm_sensors
    
    #devices
    pciutils
    usbutils

    #FHS
    (let base = pkgs.appimageTools.defaultFhsEnvArgs; in
      pkgs.buildFHSUserEnv (base // {
      name = "fhs";
      targetPkgs = pkgs: (
        # pkgs.buildFHSUserEnv provides only a minimal FHS environment,
        # lacking many basic packages needed by most software.
        # Therefore, we need to add them manually.
        #
        # pkgs.appimageTools provides basic packages required by most software.
        (base.targetPkgs pkgs) ++ [
          pkgs.pkg-config
          pkgs.ncurses
          pkgs.nix-ld
          # Feel free to add more packages here if needed.
        ]
      );
      profile = "export FHS=1;export LD_LIBRARY_PATH=${lib.makeLibraryPath [pkgs.ncurses5 pkgs.ncurses6]}:$LD_LIBRARY_PATH";
      runScript = "bash";
      extraOutputsToInstall = ["dev"];
    }))
  ];
}
