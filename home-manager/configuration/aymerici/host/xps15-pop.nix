{ lib, config, pkgs, inputs, ... }:
{
  imports = [
    #../../../modules/spotify
    #../../../modules/developer
    ../../../modules/devops
    ../../../modules/roche
    #../../../modules/work
    #../../../modules/office
    #../../../modules/gnome
  ];

  # Equalize Audio
  # https://gist.github.com/alexVinarskis/77d55a0a0f4150576ba77e5f4241d512
  home.file."${config.home.homeDirectory}/.config/pipewire/pipewire.conf.d/sink-eq6.conf" = {
    source = ./xps15-pipewire.conf;
  };

  # workarround: If I don't add this fails to find nss-cercca package, I tried to reinstall nix multiple times.. no way to make this work :(
  programs.bash = lib.mkIf config.programs.bash.enable {
    bashrcExtra = ''
      export NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
    '';
  };  
  
}
