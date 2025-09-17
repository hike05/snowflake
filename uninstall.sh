#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${RED}⚠ Snowflake Uninstaller${NC}"
echo "This will remove nix-darwin configuration"
echo "Note: This will NOT uninstall Nix itself"
echo ""
echo "Continue? [y/N]"
read -p "" -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

# Uninstall nix-darwin
if command -v darwin-rebuild &> /dev/null; then
    echo -e "${YELLOW}Uninstalling nix-darwin...${NC}"
    nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A uninstaller
    ./result/bin/darwin-uninstaller
fi

# Remove symlink
if [ -L "/etc/nix-darwin" ]; then
    echo -e "${YELLOW}Removing symlink...${NC}"
    sudo rm /etc/nix-darwin
fi

# Optional: Remove dotfiles
echo ""
echo "Remove snowflake configuration directory? [y/N]"
read -p "" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -rf ~/dotfiles
    echo -e "${GREEN}✓ Removed configuration${NC}"
fi

echo -e "${GREEN}✓ Uninstall complete${NC}"
echo ""
echo "To completely remove Nix, run:"
echo "  /nix/nix-installer uninstall"