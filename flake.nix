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

      # System CLI packages managed directly by Nix
      environment.systemPackages = [
        pkgs.git
        pkgs.curl
        pkgs.wget
        pkgs.jq
        pkgs.mas
        pkgs.zsh
        pkgs.dockutil
        # Shell & Dev prompt
        pkgs.starship
        # System monitoring
        pkgs.htop
        pkgs.btop
        pkgs.fastfetch
        # Productivity CLI replacements
        pkgs.eza          # Modern 'ls'
        pkgs.bat          # Modern 'cat'
        pkgs.ripgrep      # 'rg'
        pkgs.fd           # 'fd'
        pkgs.fzf          # Fuzzy finder
        pkgs.zoxide       # Smart directory jump
      ];

      # Homebrew management inside Nix-Darwin
      homebrew = {
        enable = true;
        onActivation.cleanup = "none";
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;

        casks = [
          "brave-browser"
          "canva"
          "applite"            # Free, open-source Homebrew App Store GUI
          "iterm2"
          "visual-studio-code" # Code editor
          "raycast"
          "rectangle"
          "the-unarchiver"
          "font-jetbrains-mono-nerd-font"
        ];
      };

      # macOS System Defaults & Clean Minimalist Dock
      system.defaults = {
        NSGlobalDomain.AppleShowAllExtensions = true;
        NSGlobalDomain.AppleInterfaceStyle = "Dark";
        finder.AppleShowAllFiles = true;
        finder.FXEnableExtensionChangeWarning = false;
        
        dock = {
          autohide = true;
          mru-spaces = false;
          show-recents = false;
          persistent-apps = [
            "/Applications/Brave Browser.app"
            "/Applications/Visual Studio Code.app"
            "/Applications/iTerm.app"
            "/Applications/Applite.app"
            "/Applications/Canva.app"
            "/Applications/ArtCraft Launcher.app"
            "/Applications/PdfCraft.app"
            "/Applications/WordCraft.app"
            "/Applications/GridCraft.app"
            "/Applications/VectorCraft.app"
            "/Applications/PhotoCraft.app"
            "/Applications/DesignCraft.app"
            "/Applications/DeckCraft.app"
            "/System/Applications/System Settings.app"
          ];
        };
      };

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