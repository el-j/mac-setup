# 🍏 MacBook Automated Provisioning & Bootstrap Suite

This repository provides reproducible, automated provisioning configurations for setting up a brand-new or freshly wiped Apple Silicon or Intel MacBook.

---

## ⚡ Zero to Hero: One-Line Install

On any fresh or wiped Mac, simply open **Terminal** (`Command + Space` -> type `Terminal`) and paste:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/el-j/mac-setup/main/install.sh)"
```

### What this command does:
1. Prompts once for your administrator password and keeps it authenticated.
2. Checks for and installs Apple Command Line Developer Tools (`xcode-select`).
3. Installs and configures **Homebrew** on your `$PATH`.
4. Clones `https://github.com/el-j/mac-setup` into `~/.mac-setup`.
5. Lets you pick **Ansible (Default)** or **Nix-Darwin** and kicks off unattended installation.

---

## 📦 What Gets Installed & Configured

### 🖥️ Applications (GUI Casks):
- 🌐 **Brave Browser** (`brave-browser`) - Privacy-first web browser.
- 🎨 **Canva Desktop** (`canva`) - Design & creative publishing app.
- 🏬 **Applite** (`applite`) - Free, open-source App Store GUI for discovering, installing, and updating Homebrew applications.
- 💻 **iTerm2** (`iterm2`) - High-performance terminal emulator with splits, hotkey window, and custom themes.
- ⚡ **Raycast** (`raycast`) - Supercharged Spotlight alternative with integrated clipboard history and window management.
- 🪟 **Rectangle** (`rectangle`) - Easy window snapping using keyboard shortcuts.
- 📦 **The Unarchiver** (`the-unarchiver`) - Universal archive unpacker (zip, rar, 7z, tar, etc.).
- 🖌️ **ArtCraft Creative Suite**:
  - **ArtCraft Launcher** (central launcher and updater for `PdfCraft`, `VectorCraft`, `PhotoCraft`, `WordCraft`, and `CADCraft`).

### 🛠️ CLI Power Tools:
- **System Monitoring**: `htop` & `btop` (interactive terminal task monitors), `fastfetch` (instant hardware & OS stats).
- **File & Search Utilities**:
  - `eza` (modern, colorized replacement for `ls` with tree views).
  - `bat` (`cat` with syntax highlighting and git integration).
  - `ripgrep` (`rg`) (ultra-fast regex searching).
  - `fd` (intuitive and faster alternative to `find`).
  - `fzf` (command-line fuzzy finder).
  - `zoxide` (`z`) (smarter navigation that remembers your most visited folders).
- **Core CLI Packages**: `git`, `curl`, `wget`, `jq`, `mas` (Mac App Store CLI), and `dockutil`.

### 🧹 Clean Minimalist Dock:
- Wipes all default Apple clutter (Keynote, Pages, Maps, Apple TV, News, Podcasts, Freeform, etc.).
- Pins only your essential apps: Brave Browser, iTerm2, Applite, Canva, and ArtCraft Launcher.

---

## 🔄 Re-running Updates in the Future

Whenever you want to re-sync your machine or apply changes:

### Using Ansible:
```bash
cd ~/.mac-setup
git pull
ansible-playbook -K playbook.yml
```

### Using Nix-Darwin:
```bash
cd ~/.mac-setup
git pull
darwin-rebuild switch --flake .#macbook
```
