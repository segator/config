{ inputs, config, pkgs,  lib, ... }:
let
    gnome-exclusion = (with pkgs.gnome; [
              cheese # webcam tool
              gnome-music
              gedit # text editor
              epiphany # web browser
              geary # email reader
              gnome-characters
              tali # poker game
              iagno # go game
              hitori # sudoku game
              atomix # puzzle game
              yelp # Help view
              gnome-contacts
              gnome-initial-setup
    ]);
in
{
    services.xserver.desktopManager.gnome.enable = true;
    programs.dconf.enable = true;
    environment.systemPackages = with pkgs; [
        gnome-tweaks
    ];

    environment.gnome.excludePackages = (with pkgs; [
              gnome-photos
              gnome-tour
            ]);
}