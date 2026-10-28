#!/usr/bin/env bash
# ==============================================================================
# macOS Bootstrap & Automated Provisioning Script
# Target Repository: https://github.com/el-j/mac-setup
# One-liner execution:
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/el-j/mac-setup/main/install.sh)"
# ==============================================================================

set -euo pipefail

# Text colors & styling
BOLD="$(tput bold 2>/dev/null || echo '')"
GREEN="$(tput setaf 2 2>/dev/null || echo '')"
BLUE="$(tput setaf 4 2>/dev/null || echo '')"
YELLOW="$(tput setaf 3 2>/dev/null || echo '')"
RED="$(tput setaf 1 2>/dev/null || echo '')"
RESET="$(tput sgr0 2>/dev/null || echo '')"

REPO_URL="https://github.com/el-j/mac-setup.git"
INSTALL_DIR="$HOME/.mac-setup"

info()    { printf "%b[INFO]%b %s\n" "${BLUE}${BOLD}" "${RESET}" "$*"; }
success() { printf "%b[SUCCESS]%b %s\n" "${GREEN}${BOLD}" "${RESET}" "$*"; }
warn()    { printf "%b[WARN]%b %s\n" "${YELLOW}${BOLD}" "${RESET}" "$*"; }
error()   { printf "%b[ERROR]%b %s\n" "${RED}${BOLD}" "${RESET}" "$*"; exit 1; }

# Verify Darwin OS
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

# Keep sudo timestamp active during script execution
info "Authenticating with sudo privileges..."
sudo -v
while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
done 2>/dev/null &

# Determine architecture prefix
ARCH="$(uname -m)"
if [[ "$ARCH" == "arm64" ]]; then
    BREW_PREFIX="/opt/homebrew"
else
    BREW_PREFIX="/usr/local"
fi

# 1. Check & install Apple Command Line Developer Tools
if ! xcode-select -p &>/dev/null; then
    info "Command Line Tools not detected. Initiating installer..."
    touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    PROD=$(softwareupdate -l | grep -B 1 -E "Command Line Tools" | awk -F'*' '/^ *\*/ {print $2}' | sed -e 's/^ *//' | tr -d '\n')
    if [[ -n "$PROD" ]]; then
        info "Installing: $PROD"
        softwareupdate -i "$PROD" --verbose
    else
        xcode-select --install
        echo "Press any key when Command Line Tools finish installing..."
        read -n 1 -r
    fi
    rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    success "Apple Command Line Developer Tools installed."
else
    success "Command Line Developer Tools are already present."
fi

# 2. Check & install Homebrew
if ! command -v brew &>/dev/null && [[ ! -x "${BREW_PREFIX}/bin/brew" ]]; then
    info "Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Export Homebrew environment variables into current execution
eval "$("${BREW_PREFIX}/bin/brew" shellenv)"
success "Homebrew is active at: $(which brew)"

# 3. Clone or pull configuration repository
if [[ -d "$INSTALL_DIR/.git" ]]; then
    info "Existing configuration found in ${INSTALL_DIR}. Pulling latest changes..."
    git -C "$INSTALL_DIR" pull --ff-only || warn "Could not pull latest changes; continuing with existing directory."
else
    info "Cloning repository ${REPO_URL} into ${INSTALL_DIR}..."
    rm -rf "$INSTALL_DIR"
    git clone "$REPO_URL" "$INSTALL_DIR"
fi

cd "$INSTALL_DIR"

# 4. Engine selection: Ansible (default) or Nix-Darwin
echo ""
echo "${BOLD}Choose provisioning engine:${RESET}"
echo "  1) Ansible Playbook (Recommended - fast, simple, no custom daemons)"
echo "  2) Nix-Darwin (Declarative flake configuration)"
echo ""

PROMPT_ENGINE="1"
if [[ -t 0 ]]; then
    read -r -p "Enter choice [1 or 2, default is 1]: " PROMPT_ENGINE
fi

case "$PROMPT_ENGINE" in
    2)
        info "Setting up with Nix-Darwin..."
        if ! command -v nix &>/dev/null; then
            info "Installing Determinate Systems Nix installer..."
            curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm
            # shellcheck disable=SC1091
            . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        fi

        FLAKE_TARGET="macbook"
        if [[ "$ARCH" == "x86_64" ]]; then
            FLAKE_TARGET="macbook-intel"
        fi

        info "Applying Nix-Darwin flake configuration (#${FLAKE_TARGET})..."
        nix run nix-darwin -- switch --flake ".#${FLAKE_TARGET}"
        ;;
    *)
        info "Setting up with Ansible Playbook..."
        if ! command -v ansible-playbook &>/dev/null; then
            info "Installing Ansible via Homebrew..."
            brew install ansible
        fi

        info "Running playbook.yml..."
        ansible-playbook -K playbook.yml
        ;;
esac

success "macOS setup completed successfully!"
info "Restarting your terminal session or rebooting is recommended to finalize all changes."
