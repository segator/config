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

  # pencil drawing screen tool
  services.gromit-mpx = {
    enable = true;
    hotKey = "F9";
    undoKey = "F10";

    tools = [
      {
        color = "red";
        device = "default";
        size = 5;
        type = "pen";
      }
      {
        color = "green";
        modifiers = [ "CONTROL" ];
        size = 5;
        device = "xwayland-touch:15";
        type = "pen";
      }
      {
        color = "blue";
        device = "xwayland-touch:15";
        modifiers = [ "2" ];
        size = 5;
        type = "pen";
      }
      {
        color = "yellow";
        device = "xwayland-touch:15";
        modifiers = [ "3" ];
        size = 5;
        type = "pen";
      }
      {
        arrowSize = 1;
        color = "green";
        device = "xwayland-touch:15";
        modifiers = [ "4" ];
        size = 6;
        type = "pen";
      }
      {
        device = "default";
        modifiers = [ "SHIFT" ];
        size = 75;
        type = "eraser";
      }
    ];

  };
}