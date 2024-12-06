
{ config, pkgs, ... }: {
  home.username = "alice";
  home.homeDirectory = "/home/alice";
  programs = {
    zsh = {
      enable = true;
      shell = true;
      enableSyntaxHighlighting = true;
      enableAutosuggestions = true;
      extraConfig = 'eval "$(starship init zsh)"';
    };
    starship = {
      enable = true;
      config = "/etc/nixos/starship.toml";
    };
    tmux = { enable = true; };
    wezterm = { enable = true; };
    neovim = {
      enable = true;
      package = pkgs.neovim;
      extraConfig = 'let g:have_nerd_font = 1';
    };
  };
  home.packages = with pkgs; [ git make unzip gcc fzf exa bat ripgrep direnv nodejs go wezterm zsh tmux starship neovim ];
  home.file = {
    ".tmux.conf" = { text = 'set -g prefix C-a
bind C-a send-prefix'; };
    ".config/wezterm/wezterm.lua" = {
      text = 'local wezterm = require "wezterm"; return { font = wezterm.font("Fira Code"), font_size = 12.0, color_scheme = "Gruvbox Dark" }';
    };
  };
  programs.direnv.enable = true;
}
