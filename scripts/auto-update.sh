#!/usr/bin/env bash

# Цей скрипт буде викликатись з .bashrc або .zshrc
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
UPDATE_FILE="$HOME/.local/state/nvim_setup_last_update"
UPDATE_INTERVAL=$((7 * 24 * 60 * 60)) # 7 днів у секундах

# Створюємо директорію, якщо її нема
mkdir -p "$HOME/.local/state"

if [ -f "$UPDATE_FILE" ]; then
    LAST_UPDATE=$(cat "$UPDATE_FILE")
else
    LAST_UPDATE=0
fi

EPOCH=$(date +%s)

if [ $((EPOCH - LAST_UPDATE)) -gt $UPDATE_INTERVAL ]; then
    echo -e "\033[1;33m[Nvim-Setup]\033[0m Час оновлюватися! Перевіряю зміни в репозиторії..."
    if (cd "$REPO_DIR" && git pull origin main); then
        echo "$EPOCH" > "$UPDATE_FILE"
        echo -e "\033[0;32mГотово! Оновлено.\033[0m"
    else
        echo -e "\033[0;31mНе вдалося оновити репозиторій. Пропускаю.\033[0m"
    fi
fi