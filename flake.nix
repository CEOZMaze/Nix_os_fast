# /etc/nixos/flake.nix

{
  description = "NixOS Configuration for Lenovo ThinkPad E470 with Hyprland and WezTerm";

  inputs = {
    # Nix Packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05"; # Use the latest stable release

    # NixOS Hardware Modules
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Home Manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Flake Utils
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, nixos-hardware, home-manager, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        # Import NixOS hardware modules
        nixosModules = import nixos-hardware { inherit system; };
      in {
        nixosConfigurations.thinkpad-e470 = nixos-hardware.lib.nixosSystem {
          inherit system;
          modules = [
            # Import the specific hardware profile for ThinkPad E470
            nixosModules.lenovo.thinkpad.e470

            # NixOS default configurations
            ({ config, pkgs, ... }: {
              imports = [
                ./hardware-configuration.nix
                home-manager.nixosModules.home-manager
              ];

              networking = {
                hostName = "thinkpad-e470"; # Your hostname
                networkmanager.enable = true; # Enable NetworkManager
              };

              time = {
                timeZone = "America/New_York"; # Your timezone
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

              # Disable X11 and enable Wayland
              services.xserver.enable = false;
              services.wayland.enable = true;

              # Enable Hyprland
              services.hyprland = {
                enable = true;
                configFile = "/etc/nixos/hyprland.conf"; # Path to your Hyprland config
              };

              # Enable PipeWire for audio
              services.pipewire = {
                enable = true;
                alsa.enable = true;
                pulse.enable = true;
              };

              # Enable Waybar (status bar) and Mako (notification daemon)
              services.waybar.enable = true;
              services.mako.enable = true;

              # Install system-wide packages
              environment.systemPackages = with pkgs; [
                wezterm
                zsh
                tmux
                starship
                fzf
                exa
                bat
                ripgrep
                direnv
                git
                waybar
                mako
                wl-clipboard
                grim
                slurp
                nerd-fonts-fira-code # Install a Nerd Font
                neovim
                nodejs # For TypeScript
                go # For Golang
                gcc # C Compiler
                make
                unzip
              ];

              # Set Zsh as the default shell
              programs.zsh = {
                enable = true;
                shell = true;
              };

              # Configure Starship prompt via Home Manager
              programs.starship.enable = true;

              # Configure Tmux via Home Manager
              programs.tmux.enable = true;

              # Allow unfree packages if needed
              nixpkgs.config.allowUnfree = true;

              # Filesystem configuration (replace UUIDs accordingly)
              fileSystems."/" = {
                device = "/dev/disk/by-uuid/YOUR_ROOT_UUID";
                fsType = "ext4";
              };

              fileSystems."/home" = {
                device = "/dev/disk/by-uuid/YOUR_HOME_UUID";
                fsType = "ext4";
              };

              swapDevices = [
                {
                  device = "/swapfile";
                  swapSize = 4096; # 4GB swap
                }
              ];

              # Security: Enable sudo for wheel group
              security.sudo.enable = true;
              security.sudo.wheelNeedsPassword = true;

              # Optimize parallel building based on CPU (i5-7200u: 2 cores, 4 threads)
              nix.settings.maxJobs = 4;

              # Home Manager integration
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

              # Import Home Manager configuration
              home-manager.configuration = import ./home.nix;
            })
          ];
        };
      }
    );
}
