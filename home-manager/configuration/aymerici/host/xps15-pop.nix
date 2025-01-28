{ config, pkgs, inputs, ... }:
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
}
