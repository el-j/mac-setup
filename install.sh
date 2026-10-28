#!/usr/bin/env bash
# ==============================================================================
# macOS Bootstrap & Automated Provisioning Script
# Target Repository: https://github.com/el-j/mac-setup
# One-liner execution:
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/el-j/mac-setup/main/install.sh)"
# ==============================================================================

set -euo pipefail

BOLD="$(tput bold 2>/dev/null || echo '')"
GREEN="$(tput setaf 2 2>/dev/null || echo '')"
BLUE="$(tput setaf 4 2>/dev/null || echo '')"
YELLOW="$(tput setaf 3 2>/dev/null || echo '')"
RED="$(tput setaf 1 2>/dev/null || echo '')"
RESET="$(tput sgr0 2>/dev/null || echo '')"

REPO_URL="https://github.com/el-j/mac-setup.git"
RAW_BASE_URL="https://raw.githubusercontent.com/el-j/mac-setup/main"
INSTALL_DIR="$HOME/.mac-setup"

info()    { printf "%b[INFO]%b %s\n" "${BLUE}${BOLD}" "${RESET}" "$*"; }
success() { printf "%b[SUCCESS]%b %s\n" "${GREEN}${BOLD}" "${RESET}" "$*"; }
warn()    { printf "%b[WARN]%b %s\n" "${YELLOW}${BOLD}" "${RESET}" "$*"; }
error()   { printf "%b[ERROR]%b %s\n" "${RED}${BOLD}" "${RESET}" "$*"; exit 1; }

# Verify macOS
if [[ "$(uname -s)" != "Darwin" ]]; then
    error "This setup script is strictly intended for macOS."
fi

cat << "EOF"
   __  ___           ____       __               
  /  |/  /__ _____  / __/__ ___/ /___ _____  ___
 / /|_/ / _ `/ __/ _\ \/ -_) _  / // / _ \/ _ \
/_/  /_/\_,_/\__/ /___/\__/\_,_/\_,_/ .__/\___/
                                    /_/          
EOF

info "Starting macOS Automated Provisioning Setup..."

# Keep sudo alive
info "Authenticating with sudo privileges..."
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Determine CPU architecture & brew prefix
ARCH="$(uname -m)"
if [[ "$ARCH" == "arm64" ]]; then
    BREW_PREFIX="/opt/homebrew"
else
    BREW_PREFIX="/usr/local"
fi

# 1. Install Command Line Tools
if ! xcode-select -p &>/dev/null; then
    info "Installing Apple Command Line Developer Tools..."
    touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    xcode-select --install || true
    echo "Press any key when the Apple Command Line Tools installation finishes..."
    read -n 1 -r
    rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    success "Apple Command Line Developer Tools ready."
else
    success "Command Line Developer Tools are already installed."
fi

# 2. Install Homebrew
if ! command -v brew &>/dev/null && [[ ! -x "${BREW_PREFIX}/bin/brew" ]]; then
    info "Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

eval "$("${BREW_PREFIX}/bin/brew" shellenv)"
success "Homebrew is active at: $(which brew)"

# 3. Setup workspace directory
mkdir -p "$INSTALL_DIR"

if git ls-remote "$REPO_URL" &>/dev/null; then
    if [[ -d "$INSTALL_DIR/.git" ]]; then
        info "Pulling latest changes into ${INSTALL_DIR}..."
        git -C "$INSTALL_DIR" pull --ff-only || true
    else
        info "Cloning ${REPO_URL} into ${INSTALL_DIR}..."
        git clone "$REPO_URL" "$INSTALL_DIR" || true
    fi
fi

cd "$INSTALL_DIR"

# Ensure playbook.yml exists (downloads from raw repo if not present in clone)
if [[ ! -f "playbook.yml" ]]; then
    info "playbook.yml not found locally. Fetching latest playbook from repository..."
    if ! curl -fsSL "${RAW_BASE_URL}/playbook.yml" -o playbook.yml; then
        warn "Could not fetch remote playbook.yml. Please make sure files are pushed to github.com/el-j/mac-setup."
    fi
fi

# 4. Engine selection
echo ""
echo "${BOLD}Choose provisioning engine:${RESET}"
echo "  1) Ansible Playbook (Recommended - Fast & installs everything)"
echo "  2) Nix-Darwin (Declarative Flake)"
echo ""

PROMPT_ENGINE="1"
if [[ -t 0 ]]; then
    read -r -p "Enter choice [1 or 2, default is 1]: " PROMPT_ENGINE
fi

case "$PROMPT_ENGINE" in
    2)
        info "Configuring via Nix-Darwin..."
        if ! command -v nix &>/dev/null; then
            curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm
            # shellcheck disable=SC1091
            . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        fi

        FLAKE_TARGET="macbook"
        if [[ "$ARCH" == "x86_64" ]]; then
            FLAKE_TARGET="macbook-intel"
        fi

        nix run nix-darwin -- switch --flake ".#${FLAKE_TARGET}"
        ;;
    *)
        info "Setting up with Ansible Playbook..."
        if ! command -v ansible-playbook &>/dev/null; then
            info "Installing Ansible via Homebrew..."
            brew install ansible
        fi

        if [[ ! -f "playbook.yml" ]]; then
            error "playbook.yml is missing in ${INSTALL_DIR}. Ensure you pushed playbook.yml to https://github.com/el-j/mac-setup"
        fi

        info "Running Ansible Playbook..."
        ansible-playbook -K playbook.yml
        ;;
esac

success "Setup successfully completed!"
