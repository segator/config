{ config, pkgs, ... }:
{
  programs.kitty.enable = true;
  programs.kitty.shellIntegration.enableFishIntegration = true;
  programs.kitty.theme = "Catppuccin-Macchiato";
  programs.kitty.settings =  {
    confirm_os_window_close=0;
    font_size = 14;
    font_family = "JetBrainsMono";
    copy_on_select="yes";
    draw_minimal_borders="yes";
    linux_display_server="x11";
    initial_window_width=240;
    initial_window_height=240;
    background_opacity="0.85";
    background_blur=10;
  };
}