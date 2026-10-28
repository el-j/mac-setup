{
  description = "MacBook Declarative Nix-Darwin Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    configuration = { pkgs, ... }: {
      # Allow unfree packages
      nixpkgs.config.allowUnfree = true;

      # Enable Nix experimental features (Flakes)
      nix.settings.experimental-features = "nix-command flakes";

      # System Packages (CLI)
      environment.systemPackages = with pkgs; [
        git
        curl
        wget
        jq
        mas
        zsh
      ];

      # Homebrew Integration
      homebrew = {
        enable = true;
        onActivation = {
          autoUpdate = true;
          upgrade = true;
          cleanup = "zap"; # Clean untracked formulae/casks
        };

        # Taps
        taps = [
          "homebrew/cask"
          "komi-store/komi-store"
        ];

        # GUI Casks
        casks = [
          "brave-browser"  # Brave Browser
          "canva"          # Canva App
          "komi-store"     # Free Open Source App Store Alternative
        ];
      };

      # Post-activation script to download & install ArtCraft Suite Launcher
      system.activationScripts.postActivation.text = ''
        echo "Configuring ArtCraft Suite..."
        if [ ! -d "/Applications/ArtCraft Launcher.app" ]; then
          echo "Installing ArtCraft Launcher (manages PdfCraft, VectorCraft, PhotoCraft)..."
          DMG_URL="https://github.com/storytold/craft-launcher/releases/download/v0.8.1/artcraft-launcher-0.8.1-macos-universal.dmg"
          curl -sSL "$DMG_URL" -o /tmp/artcraft-launcher.dmg
          hdiutil attach /tmp/artcraft-launcher.dmg -nobrowse -mountpoint /Volumes/ArtCraftLauncher
          cp -R "/Volumes/ArtCraftLauncher/ArtCraft Launcher.app" /Applications/
          hdiutil detach /Volumes/ArtCraftLauncher -force || true
          rm -f /tmp/artcraft-launcher.dmg
          xattr -dr com.apple.quarantine "/Applications/ArtCraft Launcher.app" || true
          echo "ArtCraft Launcher successfully installed."
        fi
      '';

      # macOS System Preferences
      system.defaults = {
        dock.autohide = true;
        finder = {
          AppleShowAllExtensions = true;
          AppleShowAllFiles = true;
          FXEnableExtensionChangeWarning = false;
        };
        NSGlobalDomain = {
          AppleShowAllExtensions = true;
          InitialKeyRepeat = 15;
          KeyRepeat = 2;
        };
      };

      # Compatibility settings
      system.stateVersion = 5;
    };
  in
  {
    darwinConfigurations."macbook" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin"; # Set to "x86_64-darwin" if on an Intel Mac
      modules = [ configuration ];
    };
  };
}