{ config, pkgs, ... }:
{
  nixpkgs.overlays = [
    (self: super: {
      google-chrome = super.google-chrome.override {
        commandLineArgs = [
          "--enable-features=TouchpadOverscrollHistoryNavigation,VaapiVideoDecoder,VaapiVideoEncoder"
          ];
      };
    })
  ];
  home.packages = with pkgs; [
    firefox      
    google-chrome
  ];
}