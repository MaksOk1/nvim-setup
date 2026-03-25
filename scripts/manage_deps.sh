#!/usr/bin/env bash

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

detect_distro_group() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        local os_id=$ID
    else
        echo "unknown"
        return
    fi

    case $os_id in
        ubuntu|debian|linuxmint|pop|kali)
            echo "debian"
            ;;
        arch|manjaro|endeavouros|garuda)
            echo "arch"
            ;;
        fedora|rocky|almalinux)
            echo "fedora"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

check_and_install_deps() {
    DISTRO_GROUP=$(detect_distro_group)
    echo -e "${YELLOW}Визначено групу ОС: $DISTRO_GROUP${NC}"

    case $DISTRO_GROUP in
        "arch")
            INSTALL_CMD="sudo pacman -S --needed --noconfirm"
            DEPS=("base-devel" "unzip" "ripgrep" "fd" "git" "curl")
            ;;
        "debian")
            sudo apt-get update
            INSTALL_CMD="sudo apt-get install -y"
            DEPS=("build-essential" "unzip" "ripgrep" "fd-find" "git" "curl")
            ;;
        "fedora")
            INSTALL_CMD="sudo dnf install -y"
            DEPS=("@development-tools" "unzip" "ripgrep" "fd-find" "git" "curl")
            ;;
        *)
            echo -e "${RED}Група ОС не підтримується для авто-встановлення залежностей.${NC}"
            return 1
            ;;
    esac

    TO_INSTALL=()
    for dep in "${DEPS[@]}"; do
        # Ігноруємо мета-пакети при перевірці через command
        if [[ "$dep" == "base-devel" || "$dep" == "build-essential" || "$dep" == "@development-tools" ]]; then
            continue
        fi
        
        if ! command -v "$dep" &> /dev/null; then
            TO_INSTALL+=("$dep")
        fi
    done

    # Перевірка мета-пакетів
    if [[ $DISTRO_GROUP == "arch" ]] && ! pacman -Qs base-devel &> /dev/null; then TO_INSTALL+=("base-devel"); fi
    if [[ $DISTRO_GROUP == "debian" ]] && ! dpkg -s build-essential &> /dev/null; then TO_INSTALL+=("build-essential"); fi
    if [[ $DISTRO_GROUP == "fedora" ]] && ! dnf list installed @development-tools &> /dev/null; then TO_INSTALL+=("@development-tools"); fi

    if [ ${#TO_INSTALL[@]} -ne 0 ]; then
        echo -e "${YELLOW}Встановлення залежностей: ${TO_INSTALL[*]}${NC}"
        $INSTALL_CMD "${TO_INSTALL[@]}"
        
        # Фікс для fd на Debian/Fedora
        if [[ $DISTRO_GROUP == "debian" || $DISTRO_GROUP == "fedora" ]] && command -v fdfind &> /dev/null; then
            sudo ln -sf $(which fdfind) /usr/local/bin/fd
        fi
    else
        echo -e "${GREEN}Всі залежності вже встановлені.${NC}"
    fi
}