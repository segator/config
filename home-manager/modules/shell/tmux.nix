{ config, pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    shell = "${pkgs.fish}/bin/fish";
    terminal = "tmux-256color";
    historyLimit = 100000;
    plugins = with pkgs;
      [
        tmuxPlugins.better-mouse-mode
        tmuxPlugins.catppuccin
      ];
    extraConfig = ''
    setw -g mouse on
    set -g @catppuccin_flavour 'macchiato'
    set -g @catppuccin_window_tabs_enabled on
    set -g @catppuccin_date_time "%H:%M"
    '';
  };
}
