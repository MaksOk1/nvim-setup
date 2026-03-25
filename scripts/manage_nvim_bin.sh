#!/usr/bin/env bash

# Кольори
YELLOW='\033[1;33m'
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

check_and_install_nvim() {
    if ! command -v nvim &> /dev/null; then
        echo -e "${YELLOW}Neovim не знайдено.${NC}"
        install_nightly
    else
        CURRENT_VER=$(nvim --version | head -n1 | grep -oP 'v\K[0-9]+\.[0-9]+\.[0-9]+' || echo "0.0.0")
        REQUIRED_VER="0.11.0"

        echo -e "Поточна версія Neovim: ${GREEN}$CURRENT_VER${NC}"

        if [ "$(printf '%s\n%s' "$REQUIRED_VER" "$CURRENT_VER" | sort -V | head -n1)" != "$REQUIRED_VER" ]; then
            echo -e "${RED}Увага: Версія Neovim нижче за $REQUIRED_VER!${NC}"
            read -p "Встановити Neovim Nightly? (y/n): " confirm
            [[ $confirm == [yY] ]] && install_nightly
        fi
    fi
}

install_nightly() {
    echo -e "${YELLOW}Встановлення Neovim Nightly...${NC}"
    curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim-linux-x86_64.tar.gz
    sudo rm -rf /opt/nvim-linux-x86_64
    sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
    sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
    rm nvim-linux-x86_64.tar.gz
    echo -e "${GREEN}Neovim Nightly успішно встановлено в /usr/local/bin/nvim${NC}"
}