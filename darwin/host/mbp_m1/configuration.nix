{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../defaults.nix
    ../modules/homebrew
  ];
  nixpkgs.hostPlatform = "aarch64-darwin";
  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  #environment.darwinConfig = "$HOME/src/dotfiles/hosts/jeff_laptop/default.nix";

  networking.hostName = "aymerici-4DVF0G";

  # TODO: already set during installation of OS?
  time.timeZone = lib.mkDefault "Europe/Madrid";

  users.users.aymerici = {
    description = "aymerici";
    shell = pkgs.fish;
    home = "/Users/aymerici";
  };

  homebrew = {
   casks = [     
      "google-chrome"
      "discord"
      "iterm2"      
      "microsoft-remote-desktop"      
      "slack"
      "spotify"
      "shottr" # screenshot tool      
      "vlc" # video player
      "visual-studio-code"
      "XQuartz" # X11 for macOS
      "zoom"
    ];
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}