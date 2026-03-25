#!/usr/bin/env bash

# Кольори
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

TARGET="$HOME/.config/nvim"

# Перевірка, чи вже встановлено щось
if [ -e "$TARGET" ]; then
    echo -e "${YELLOW}Попередження: Конфігурація Neovim вже існує ($TARGET).${NC}"
    read -p "Бажаєш перезаписати її? (y/n): " choice
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
        "Вихід")
            exit 0
            ;;
        *) echo -e "${RED}Невірний вибір${NC}";;
    esac
done

# Створення симлінка (використовуємо повний шлях через readlink)
SOURCE_DIR="$(cd "$(dirname "$0")" && pwd)/$CONF"

if [ -d "$SOURCE_DIR" ]; then
    ln -s "$SOURCE_DIR" "$TARGET"
    echo -e "${GREEN}Успішно встановлено $CONF!${NC}"
    echo "Запускай 'nvim', щоб ініціалізувати плагіни."
else
    echo -e "${RED}Помилка: Папка $SOURCE_DIR не знайдена!${NC}"
    exit 1
fi