{ inputs, config, pkgs,  lib, ... }: {   
   nixpkgs.config.allowUnfree = true;
   nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];    
    auto-optimise-store = true;
    extra-platforms = [ "aarch64-linux" ];
  };
  
  # Auto delete old generations
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 30d";
}
  
  
