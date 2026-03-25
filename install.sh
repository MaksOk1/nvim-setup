#!/usr/bin/env bash

# Кольори
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

source "$SCRIPT_DIR/scripts/manage_deps.sh"
source "$SCRIPT_DIR/scripts/manage_nvim_bin.sh"

echo -e "${GREEN}=== Початок встановлення ===${NC}"

check_and_install_deps
check_and_install_nvim

TARGET="$HOME/.config/nvim"

# Перевірка, чи вже встановлено щось
if [ -e "$TARGET" ]; then
    echo -e "${YELLOW}Попередження: Конфігурація Neovim вже існує ($TARGET).${NC}"
    read -p "Бажаєш перезаписати її? (y/N): " choice
    if [[ ! $choice =~ ^[Yy]$ ]]; then
        echo "Скасовано."
        exit 0
    fi
    
    # Видалення старого симлінка або бекап директорії
    if [ -L "$TARGET" ]; then
        rm "$TARGET"
    else
        BACKUP="${TARGET}_backup_$(date +%s)"
        mv "$TARGET" "$BACKUP"
        echo -e "${YELLOW}Стару папку переміщено в $BACKUP${NC}"
    fi
fi

echo -e "${GREEN}Обери конфігурацію для встановлення:${NC}"
# Важливо: назви мають збігатися з папками в репо
options=("nvim-full" "nvim-minimal" "Вихід")
select opt in "${options[@]}"
do
    case $opt in
        "nvim-full"|"nvim-minimal")
            CONF=$opt
            break
            ;;
        "Вихід") exit 0 ;;
        *) echo -e "${RED}Невірний вибір${NC}" ;;
    esac
done

# Створення симлінка (використовуємо повний шлях через readlink)
SOURCE_DIR="$(cd "$(dirname "$0")" && pwd)/$CONF"
# SOURCE_DIR="$SCRIPT_DIR/$CONF"

if [ -d "$SOURCE_DIR" ]; then
    ln -s "$SOURCE_DIR" "$TARGET"
    echo -e "${GREEN}Успішно встановлено $CONF!${NC}"
    echo "Можеш запускати 'nvim'!"
else
    echo -e "${RED}Помилка: Папка $SOURCE_DIR не знайдена!${NC}"
    exit 1
fi

# --- АВТООНОВЛЕННЯ ---
read -p "Увімкнути автооновлення конфігу (раз на 7 днів при старті терміналу)? (y/n): " auto_upd
if [[ $auto_upd == [yY] ]]; then
    SHELL_RC="$HOME/.$(basename $SHELL)rc"
    # Fallback, якщо SHELL вказує на щось дивне
    [[ "$SHELL" == */zsh ]] && SHELL_RC="$HOME/.zshrc"
    [[ "$SHELL" == */bash ]] && SHELL_RC="$HOME/.bashrc"
    
    UPDATE_BLOCK="\n# Auto-update nvim-setup\nif [ -f \"$SCRIPT_DIR/scripts/auto_update.sh\" ]; then\n    source \"$SCRIPT_DIR/scripts/auto_update.sh\"\nfi\n"
    
    if ! grep -q "Auto-update nvim-setup" "$SHELL_RC" 2>/dev/null; then
        echo -e "$UPDATE_BLOCK" >> "$SHELL_RC"
        echo -e "${GREEN}Автооновлення успішно додано в $SHELL_RC${NC}"
    else
        echo -e "${YELLOW}Хук автооновлення вже існує в $SHELL_RC${NC}"
    fi
fi