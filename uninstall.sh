#!/usr/bin/env bash

TARGET="$HOME/.config/nvim"

# Видалення сімлінків
if [ -L "$TARGET" ]; then
    rm "$TARGET"
    echo "Симлінк $TARGET видалено."
elif [ -d "$TARGET" ]; then
    echo "Знайдено реальну папку замість симлінка. Видалити вручну."
else
    echo "Активний симлінк не знайдений."
fi

# Видалення бінарника (опціонально)
if [ -f "/usr/local/bin/nvim" ]; then
    read -p "Видалити встановлений nvim з /usr/local/bin? (y/N): " del_bin
    if [[ $del_bin == [yY] ]]; then
        sudo rm /usr/local/bin/nvim
        sudo rm -rf /opt/nvim-linux-x86_64
        echo "Бінарник видалено."
    fi
fi

# Перевірка наявності бекапів
if ls -d "${TARGET}_backup_"* >/dev/null 2>&1; then
    read -p "Знайдено бекапи. Відновити останній? (y/N): " confirm
    if [[ $confirm == [yY] ]]; then
        LATEST_BACKUP=$(ls -td ${TARGET}_backup_* | head -1)
        mv "$LATEST_BACKUP" "$TARGET"
        echo "Бекап $LATEST_BACKUP відновлено."
    fi
fi