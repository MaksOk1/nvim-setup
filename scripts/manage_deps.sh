#!/usr/bin/env bash

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Перевірка Xcode Command Line Tools (тільки для macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    if ! xcode-select -p &>/dev/null; then
        echo -e "${YELLOW}Xcode Command Line Tools не знайдено. Встановлення...${NC}"
        xcode-select --install
        echo "Будь ласка, завершіть встановлення у вікні, що з'явилося, і запустіть цей скрипт знову."
        exit 1
    fi
fi

# Перевірка Git
if ! command -v git &> /dev/null; then
    echo -e "${YELLOW}Git не знайдено. Встановлення...${NC}"
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt update && sudo apt install -y git
    else
        echo "Будь ласка, встановіть Git або Xcode Command Line Tools."
        exit 1
    fi
fi

detect_distro_group() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
        return
    fi

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
        "macos")
            # Перевірка наявності Homebrew
            if ! command -v brew &> /dev/null; then
                echo -e "${YELLOW}Homebrew не знайдено.${NC}"
                read -p "Встановити Homebrew? (y/N): " choice
                if [[ $choice == [yY] ]]; then
                    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

                    # Визначаємо шлях до brew залежно від архітектури
                    if [[ -f /opt/homebrew/bin/brew ]]; then
                        BREW_PATH="/opt/homebrew/bin/brew" # Apple Silicon Mac
                    elif [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]]; then
                        BREW_PATH="/home/linuxbrew/.linuxbrew/bin/brew" # Linux
                    else
                        BREW_PATH="/usr/local/bin/brew" # Intel Mac
                    fi

                    # Додаємо в конфіг поточної оболонки
                    SHELL_TYPE=$(basename "$SHELL")
                    CONFIG_FILE="$HOME/.${SHELL_TYPE}rc"
                    # SHELL_CONFIG="$HOME/.$(basename $SHELL
                    [[ "$SHELL_TYPE" == */zsh ]] && CONFIG_FILE="$HOME/.zprofile"

                    echo "Налаштування PATH у $CONFIG_FILE..."
                    echo "eval \"\$($BREW_PATH shellenv)\"" >> "$CONFIG_FILE"
                    eval "$($BREW_PATH shellenv)"

                    echo -e "${YELLOW}Homebrew успішно встановлено та налаштовано!${NC}"
                fi
            fi
            INSTALL_CMD="brew install"
            DEPS=("unzip" "ripgrep" "fd" "git" "node")
            ;;
        "arch")
            INSTALL_CMD="sudo pacman -S --needed --noconfirm"
            DEPS=("base-devel" "unzip" "ripgrep" "fd" "git" "curl" "npm" "nodejs")
            ;;
        "debian")
            sudo apt-get update
            INSTALL_CMD="sudo apt-get install -y"
            DEPS=("build-essential" "unzip" "ripgrep" "fd-find" "git" "curl" "npm" "nodejs")
            ;;
        "fedora")
            INSTALL_CMD="sudo dnf install -y"
            DEPS=("@development-tools" "unzip" "ripgrep" "fd-find" "git" "curl" "npm" "nodejs")
            ;;
        *)
            echo -e "${RED}Група ОС не підтримується для авто-встановлення залежностей.${NC}"
            return 1
            ;;
    esac

    TO_INSTALL=()
    for dep in "${DEPS[@]}"; do
        # Ігноруємо мета-пакети при перевірці через command
        # Ігноруємо мета-пакети та специфічні для Linux назви при перевірці на macOS
        if [[ "$dep" == "base-devel" || "$dep" == "build-essential" || "$dep" == "@development-tools" ]]; then
            continue
        fi
        
        # На macOS 'node' включає 'npm', тому перевіряємо 'node'
        if ! command -v "$dep" &> /dev/null; then
            TO_INSTALL+=("$dep")
        fi
    done

    # Перевірка мета-пакетів (тільки для Linux)
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