# 🍏 MacBook Automated Provisioning & Bootstrap Suite

This repository provides reproducible, automated provisioning configurations for setting up a brand-new or freshly wiped Apple Silicon or Intel MacBook.

---

## 📦 What Gets Installed & Configured

1. **Package Management**:
   - [Homebrew](https://brew.sh) (native macOS package manager).
   - `mas` (Mac App Store CLI for automated App Store installations).

2. **Core Applications & Requested Tools**:
   - 🌐 **Brave Browser** (`brave-browser` cask)
   - 🎨 **Canva Desktop** (`canva` cask)
   - 🏬 **Free / Open-Source App Store Alternative**:
     - **Komi Store** (`komi-store` - cross-platform open-source app store for GitHub/Codeberg releases)
     - **mas CLI** (command-line interface for the native Mac App Store)
   - 🖌️ **ArtCraft Creative Suite**:
     - **ArtCraft Launcher** (official centralized launcher and updater for the Craft apps built by the ArtCraft team: `PhotoCraft`, `VectorCraft`, `PdfCraft`, `WordCraft`, and `CADCraft`)
     - Direct setup and auto-install of `PdfCraft`, `VectorCraft`, and `PhotoCraft`

3. **macOS System Defaults**:
   - Show hidden files in Finder.
   - Show file extensions in Finder.
   - Disable automatic capitalization and spelling correction.
   - Prevent `.DS_Store` generation on network and USB volumes.

---

## 🚀 Choose Your Provisioning Tool

You can choose either **Option A: Ansible** (easiest to start with zero declarative learning curve) or **Option B: nix-darwin** (pure declarative reproducibility).

---

### 🔹 Option A: Ansible (Recommended for Simplicity)

#### 1. Initial Machine Setup (Run once on fresh macOS)
Open Terminal and run:

```bash
# 1. Install Apple Command Line Tools
xcode-select --install

# 2. Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 3. Add Homebrew to your PATH (Apple Silicon)
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# 4. Install Ansible and community collection
brew install ansible
ansible-galaxy collection install community.general
```

#### 2. Run the Playbook
Clone or save your files into a directory (e.g. `~/mac-provisioning`), and run:

```bash
cd ~/mac-provisioning
ansible-playbook -K playbook.yml
```
*(Enter your Mac administrator password when prompted for `BECOME password`).*

---

### 🔹 Option B: nix-darwin (Pure Declarative Setup)

If you prefer Nix to keep your entire macOS environment versioned and immutable:

#### 1. Install Nix with Flakes enabled
```bash
# Install Determinate Nix installer (recommended for macOS)
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

#### 2. Apply nix-darwin Configuration
```bash
cd ~/mac-provisioning

# Replace $(hostname -s) with your actual hostname or target machine name
nix run nix-darwin -- switch --flake .#macbook
```

Whenever you modify your `flake.nix`, simply run:
```bash
darwin-rebuild switch --flake .#macbook
```

---

## 🛠 File Hierarchy in this Repository

- `README.md`: This setup documentation.
- `playbook.yml`: The Ansible playbook automating Homebrew, casks, taps, ArtCraft Suite, and system settings.
- `flake.nix`: The declarative Nix Flake defining your system, Homebrew casks, and ArtCraft packages.