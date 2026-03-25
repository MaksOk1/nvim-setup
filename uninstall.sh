#!/usr/bin/env bash

TARGET="$HOME/.config/nvim"
BACKUP_DIR="${TARGET}_backup"

if [ -L "$TARGET" ]; then
    rm "$TARGET"
    echo "Симлінк $TARGET видалено."
else
    echo "Активний симлінк не знайдений."
fi

# Перевірка наявності бекапів
if [ -d "${TARGET}_backup_"* ]; then
    read -p "Знайдено бекапи. Відновити останній? (y/n): " confirm
    if [[ $confirm == [yY] ]]; then
        LATEST_BACKUP=$(ls -td ${TARGET}_backup_* | head -1)
        mv "$LATEST_BACKUP" "$TARGET"
        echo "Бекап $LATEST_BACKUP відновлено як основний конфіг."
    fi
fi