
{
  description = "NixOS Configuration for Lenovo ThinkPad E470 with Hyprland and WezTerm";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, nixos-hardware, home-manager, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        nixosModules = import nixos-hardware { inherit system; };
      in {
        nixosConfigurations.thinkpad-e470 = nixos-hardware.lib.nixosSystem {
          inherit system;
          modules = [
            nixosModules.lenovo.thinkpad.e470
            ({ config, pkgs, ... }: {
              imports = [
                ./hardware-configuration.nix
                home-manager.nixosModules.home-manager
              ];
              networking = {
                hostName = "thinkpad-e470";
                networkmanager.enable = true;
              };
              time = {
                timeZone = "America/New_York";
                enableNTP = true;
              };
              i18n = {
                defaultLocale = "en_US.UTF-8";
                supportedLocales = [ "en_US.UTF-8" ];
              };
              boot.loader = {
                systemd-boot.enable = true;
                efi.canTouchEfiVariables = true;
              };
              services.xserver.enable = false;
              services.wayland.enable = true;
              services.hyprland = {
                enable = true;
                configFile = "/etc/nixos/hyprland.conf";
              };
              services.pipewire = {
                enable = true;
                alsa.enable = true;
                pulse.enable = true;
              };
              services.waybar.enable = true;
              services.mako.enable = true;
              environment.systemPackages = with pkgs; [
                wezterm zsh tmux starship fzf exa bat ripgrep direnv git
                waybar mako wl-clipboard grim slurp nerd-fonts-fira-code
                neovim nodejs go gcc make unzip
              ];
              programs.zsh = { enable = true; shell = true; };
              programs.starship.enable = true;
              programs.tmux.enable = true;
              nixpkgs.config.allowUnfree = true;
              fileSystems."/" = { device = "/dev/disk/by-uuid/abcd-1234"; fsType = "ext4"; };
              fileSystems."/home" = { device = "/dev/disk/by-uuid/ijkl-5678"; fsType = "ext4"; };
              swapDevices = [{ device = "/swapfile"; swapSize = 4096; }];
              security.sudo = { enable = true; wheelNeedsPassword = true; };
              nix.settings.maxJobs = 4;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.configuration = import ./home.nix;
            })
          ];
        };
      }
    );
}
