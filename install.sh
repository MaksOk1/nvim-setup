#!/usr/bin/env bash

# Кольори для терміналу
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}Обери конфігурацію Neovim:${NC}"
options=("nvim-ide" "nvim-light" "Вихід")
select opt in "${options[@]}"
do
    case $opt in
        "nvim-ide")
            CONF="nvim-ide"
            break
            ;;
        "nvim-light")
            CONF="nvim-light"
            break
            ;;
        "Вихід")
            exit 0
            ;;
        *) echo "Невірний вибір";;
    esac
done

TARGET="$HOME/.config/nvim"

# Очищення старого (бекап за бажанням)
[ -L "$TARGET" ] && rm "$TARGET"
[ -d "$TARGET" ] && mv "$TARGET" "${TARGET}_backup_$(date +%s)"

# Створення симлінка
ln -s "$(pwd)/$CONF" "$TARGET"

echo -e "${GREEN}Встановлено $CONF. Запускай nvim!${NC}"