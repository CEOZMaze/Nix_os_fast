# /mnt/etc/nixos/home.nix

{ config, pkgs, ... }:

{
  # User Information
  home.username = "ceoz";
  home.homeDirectory = "/home/ceoz";

  # Programs Configuration
  programs = {
    # Zsh Configuration
    zsh = {
      enable = true;
      shell = true;
      enableSyntaxHighlighting = true;
      enableAutosuggestions = true;
      extraConfig = ''
        # Zsh Configuration
        eval "$(starship init zsh)"
        # Additional Zsh settings can go here
      '';
    };

    # Starship Configuration
    starship = {
      enable = true;
      config = "/etc/nixos/starship.toml";
    };

    # Tmux Configuration
    tmux = {
      enable = true;
      # Tmux configuration is managed via ~/.tmux.conf
    };

    # WezTerm Configuration
    wezterm = {
      enable = true;
      # Configuration handled via ~/.config/wezterm/wezterm.lua
    };

    # Neovim Configuration
    neovim = {
      enable = true;
      package = pkgs.neovim;
      extraConfig = ''
        let g:have_nerd_font = 1
      '';
    };
  };

  # Home Manager Packages
  home.packages = with pkgs; [
    # Essential Tools
    git
    make
    unzip
    gcc
    fzf
    exa
    bat
    ripgrep
    direnv
    nodejs
    go
    wezterm
    zsh
    tmux
    starship
    neovim
  ];

  # Home Files Configuration
  home.file = {
    ".tmux.conf" = {
      text = ''
        # Tmux Configuration
        set -g prefix C-a
        bind C-a send-prefix
        # Additional Tmux settings
      '';
    };

    ".config/wezterm/wezterm.lua" = {
      text = ''
        -- WezTerm Configuration
        local wezterm = require 'wezterm';
        return {
          font = wezterm.font("Fira Code"),
          font_size = 12.0,
          color_scheme = "Gruvbox Dark",
          -- Add more settings as needed
        }
      '';
    };

    # Neovim Configuration using kickstart.nvim
    ".config/nvim" = {
      source = builtins.fetchGit {
        url = "https://github.com/nvim-lua/kickstart.nvim.git";
        rev = "master"; # or specify a commit hash for stability
      };
    };
  };

  # Enable direnv
  programs.direnv.enable = true;
}
