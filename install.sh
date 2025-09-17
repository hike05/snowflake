#!/bin/bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}❄️  snowflake installer${NC}"
echo -e "A unique macOS configuration powered by Nix flakes"
echo ""

# Configuration
DOTFILES_DIR="$HOME/dotfiles"
SYSTEM_CONFIG_PATH="/etc/nix-darwin"
REPO_URL="https://github.com/yourusername/snowflake.git"

# Detect system architecture
ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ]; then
    NIX_SYSTEM="aarch64-darwin"
    echo -e "${GREEN}✓ Detected Apple Silicon${NC}"
else
    NIX_SYSTEM="x86_64-darwin"
    echo -e "${GREEN}✓ Detected Intel Mac${NC}"
fi

# Get hostname
HOSTNAME=$(scutil --get LocalHostName)
echo -e "${GREEN}✓ Hostname: $HOSTNAME${NC}"

# Step 1: Xcode Command Line Tools
echo -e "\n${YELLOW}Step 1: Installing Xcode Command Line Tools...${NC}"
if xcode-select -p &> /dev/null; then
    echo -e "${GREEN}✓ Already installed${NC}"
else
    xcode-select --install
    echo "Press Enter when installation is complete..."
    read
fi

# Step 2: Nix
echo -e "\n${YELLOW}Step 2: Installing Nix...${NC}"
if command -v nix &> /dev/null; then
    echo -e "${GREEN}✓ Already installed${NC}"
else
    curl -L https://nixos.org/nix/install | sh -s -- --daemon
    . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi

# Step 3: Clone repository
echo -e "\n${YELLOW}Step 3: Setting up snowflake configuration...${NC}"
if [ -d "$DOTFILES_DIR" ]; then
    echo -e "${YELLOW}⚠ Configuration already exists${NC}"
    echo "1) Use existing"
    echo "2) Backup and re-clone"
    read -p "Choice [1-2]: " choice
    
    case $choice in
        1)
            cd "$DOTFILES_DIR"
            git pull || true
            ;;
        2)
            mv "$DOTFILES_DIR" "$DOTFILES_DIR.backup.$(date +%Y%m%d_%H%M%S)"
            git clone "$REPO_URL" "$DOTFILES_DIR"
            ;;
    esac
else
    git clone "$REPO_URL" "$DOTFILES_DIR"
fi

# Step 4: Create symlink
echo -e "\n${YELLOW}Step 4: Creating system symlink...${NC}"
if [ ! -e "$SYSTEM_CONFIG_PATH" ]; then
    sudo ln -sfn "$DOTFILES_DIR" "$SYSTEM_CONFIG_PATH"
    echo -e "${GREEN}✓ Created symlink${NC}"
elif [ -L "$SYSTEM_CONFIG_PATH" ]; then
    echo -e "${GREEN}✓ Symlink exists${NC}"
else
    echo -e "${YELLOW}⚠ $SYSTEM_CONFIG_PATH exists but is not a symlink${NC}"
    echo "Please remove it manually and run this script again"
    exit 1
fi

# Step 5: Build configuration
echo -e "\n${YELLOW}Step 5: Building configuration...${NC}"
cd "$DOTFILES_DIR"

if grep -q "\"$HOSTNAME\"" flake.nix; then
    nix build ".#darwinConfigurations.$HOSTNAME.system" --extra-experimental-features "nix-command flakes"
else
    echo -e "${YELLOW}⚠ Hostname '$HOSTNAME' not found in flake.nix${NC}"
    echo "Using default 'macbook-pro' configuration"
    HOSTNAME="macbook-pro"
    nix build ".#darwinConfigurations.$HOSTNAME.system" --extra-experimental-features "nix-command flakes"
fi

# Step 6: Apply configuration
echo -e "\n${YELLOW}Step 6: Applying configuration...${NC}"
./result/sw/bin/darwin-rebuild switch --flake ".#$HOSTNAME"

# Step 7: Setup aliases
echo -e "\n${YELLOW}Step 7: Setting up aliases...${NC}"
if ! grep -q "alias rebuild" ~/.zshrc 2>/dev/null; then
    echo "" >> ~/.zshrc
    echo "# Snowflake aliases" >> ~/.zshrc
    echo "alias rebuild='darwin-rebuild switch --flake ~/dotfiles#$HOSTNAME'" >> ~/.zshrc
    echo "alias update='cd ~/dotfiles && nix flake update && rebuild'" >> ~/.zshrc
    echo "alias rollback='darwin-rebuild rollback'" >> ~/.zshrc
    echo -e "${GREEN}✓ Added aliases${NC}"
fi

# Complete!
echo -e "\n${GREEN}✅ Snowflake installation complete!${NC}"
echo ""
echo "Configuration locations:"
echo "  • Repository:  $DOTFILES_DIR"
echo "  • Symlink:     $SYSTEM_CONFIG_PATH -> $DOTFILES_DIR"
echo ""
echo "Useful commands:"
echo "  • ${BLUE}rebuild${NC}   - Apply configuration changes"
echo "  • ${BLUE}update${NC}    - Update all packages and rebuild"
echo "  • ${BLUE}rollback${NC}  - Rollback to previous generation"
echo ""
echo -e "${YELLOW}⚠ Please restart your terminal${NC}"