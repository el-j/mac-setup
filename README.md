<!-- ... existing code ... -->
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

1. **Package Managers**:
   - [Homebrew](https://brew.sh) (native macOS package manager).
   - `mas` (Mac App Store CLI for automated App Store installations).

2. **Core Applications & Requested Tools**:
   - 🌐 **Brave Browser** (`brave-browser` cask)
   - 🎨 **Canva Desktop** (`canva` cask)
   - 🏬 **Free / Open-Source App Store Alternative**:
     - **Komi Store** (`komi-store` - cross-platform open-source app store for GitHub/Codeberg releases)
     - **mas CLI** (command-line interface for the native Mac App Store)
   - 🖌️ **ArtCraft Creative Suite**:
     - **ArtCraft Launcher** (official centralized launcher and updater for the Craft apps: `PhotoCraft`, `VectorCraft`, `PdfCraft`, `WordCraft`, and `CADCraft`)
     - Direct setup and auto-install of `PdfCraft`, `VectorCraft`, and `PhotoCraft`

3. **macOS System Defaults**:
   - Show hidden files in Finder.
   - Show file extensions in Finder.
   - Disable automatic capitalization and spelling correction.
   - Prevent `.DS_Store` generation on network and USB volumes.

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

---

## 🛠 File Hierarchy in this Repository

- `install.sh`: The single-line curl bootstrap installer.
- `README.md`: This setup documentation.
- `playbook.yml`: The Ansible playbook automating Homebrew, casks, taps, ArtCraft Suite, and system settings.
- `flake.nix`: The declarative Nix Flake defining your system, Homebrew casks, and ArtCraft packages.
