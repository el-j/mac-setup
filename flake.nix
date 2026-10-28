{
  description = "Declarative macOS bootstrap configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, nix-homebrew }:
  let
    configuration = { pkgs, ... }: {
      nixpkgs.config.allowUnfree = true;

      # System CLI packages
      environment.systemPackages = [
        pkgs.git
        pkgs.curl
        pkgs.wget
        pkgs.jq
        pkgs.mas
        pkgs.zsh
        pkgs.dockutil
        # System monitoring
        pkgs.htop
        pkgs.btop
        pkgs.fastfetch
        # Productivity CLI utilities
        pkgs.eza
        pkgs.bat
        pkgs.ripgrep
        pkgs.fd
        pkgs.fzf
        pkgs.zoxide
      ];

      # Homebrew management inside Nix-Darwin
      homebrew = {
        enable = true;
        onActivation.cleanup = "zap";
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;

        brews = [
          "mas"
          "dockutil"
        ];

        casks = [
          "brave-browser"
          "canva"
          "applite"
          "iterm2"
          "raycast"
          "rectangle"
          "the-unarchiver"
        ];
      };

      # macOS System Defaults & Clean Dock
      system.defaults = {
        NSGlobalDomain.AppleShowAllExtensions = true;
        NSGlobalDomain.AppleInterfaceStyle = "Dark";
        finder.AppleShowAllFiles = true;
        finder.FXEnableExtensionChangeWarning = false;
        dock = {
          autohide = true;
          mru-spaces = false;
          show-recents = false;
          # Clean dock: only pin the essentials
          persistent-apps = [
            "/Applications/Brave Browser.app"
            "/Applications/iTerm.app"
            "/Applications/Applite.app"
            "/Applications/Canva.app"
            "/System/Applications/System Settings.app"
          ];
        };
      };

      system.stateVersion = 5;
    };
  in
  {
    darwinConfigurations."macbook" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin"; # Apple Silicon
      modules = [
        configuration
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = false;
            user = builtins.getEnv "USER";
          };
        }
      ];
    };

    darwinConfigurations."macbook-intel" = nix-darwin.lib.darwinSystem {
      system = "x86_64-darwin"; # Intel Macs
      modules = [
        configuration
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = false;
            user = builtins.getEnv "USER";
          };
        }
      ];
    };
  };
}
