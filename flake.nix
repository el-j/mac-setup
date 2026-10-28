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
      # Allow proprietary packages
      nixpkgs.config.allowUnfree = true;

      # System CLI packages
      environment.systemPackages = [
        pkgs.git
        pkgs.curl
        pkgs.wget
        pkgs.jq
        pkgs.mas
        pkgs.zsh
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

        taps = [
          "homebrew/cask"
          "komi-store/komi-store"
        ];

        brews = [
          "mas"
        ];

        casks = [
          "brave-browser"
          "canva"
          "komi-store"
          "iterm2"
          "raycast"
          "rectangle"
          "the-unarchiver"
        ];
      };

      # macOS System Defaults
      system.defaults = {
        NSGlobalDomain.AppleShowAllExtensions = true;
        NSGlobalDomain.AppleInterfaceStyle = "Dark";
        finder.AppleShowAllFiles = true;
        finder.FXEnableExtensionChangeWarning = false;
        dock.autohide = true;
        dock.mru-spaces = false;
      };

      # System state tracking
      system.stateVersion = 5;
    };
  in
  {
    darwinConfigurations."macbook" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin"; # Apple Silicon (M1/M2/M3/M4)
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
