#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="$SCRIPT_DIR/data"

log() {
    local log_file="$HOME/.local/share/emoji-picker.log"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$log_file" 2>/dev/null || true
}

check_dependencies() {
    local missing=()
    
    for cmd in yad xclip notify-send python3; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        log "Dependências faltando: ${missing[*]}"
        
        if command -v apt-get &>/dev/null; then
            sudo apt-get install -y "${missing[@]}" libnotify-bin 2>/dev/null || \
            apt-get install -y "${missing[@]}" libnotify-bin
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y "${missing[@]}" libnotify
        elif command -v pacman &>/dev/null; then
            sudo pacman -S --noconfirm "${missing[@]}" libnotify
        elif command -v zypper &>/dev/null; then
            sudo zypper install -y "${missing[@]}" libnotify
        fi
    fi
}

install_emoji_font() {
    if fc-list | grep -qi "Noto Color Emoji"; then
        return 0
    fi
    
    log "Fonte Noto Color Emoji não encontrada. Tentando instalar..."
    
    if command -v apt-get &>/dev/null; then
        sudo apt-get install -y fonts-noto-color-emoji 2>/dev/null || \
        apt-get install -y fonts-noto-color-emoji
        fc-cache -f -v 2>/dev/null || true
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y google-noto-color-emoji-fonts
        fc-cache -f -v 2>/dev/null || true
    elif command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm noto-fonts-emoji
        fc-cache -f -v 2>/dev/null || true
    elif command -v zypper &>/dev/null; then
        sudo zypper install -y google-noto-color-emoji-fonts
        fc-cache -f -v 2>/dev/null || true
    fi
    
    if fc-list | grep -qi "Noto Color Emoji"; then
        log "Fonte emoji instalada com sucesso!"
        return 0
    else
        yad --error --text="Não foi possível instalar a fonte emoji.\nInstale manualmente: fonts-noto-color-emoji"
        return 1
    fi
}

get_all_emojis() {
    local json_file="$DATA_DIR/emojis.json"
    
    if [ ! -f "$json_file" ]; then
        yad --error --text="Arquivo de emojis não encontrado:\n$json_file"
        return 1
    fi
    
    python3 -c "
import json

with open('$json_file', 'r', encoding='utf-8') as f:
    data = json.load(f)
    for cat_key, cat_data in data.items():
        cat_name = cat_data.get('name', cat_key)
        for item in cat_data.get('emojis', []):
            print(item[0] + '\t' + item[1] + ' [' + cat_name + ']')
" 2>/dev/null
}

show_picker() {
    local emojis=$(get_all_emojis)
    
    local chosen=$(echo "$emojis" | yad --center \
        --title="Emoji Picker" \
        --width=800 --height=600 \
        --list \
        --column="Emoji":TEXT \
        --column="Descrição" \
        --search-column=2 \
        --print-column=1 \
        --separator="" \
        --no-headers \
        --text="Selecione um emoji (digite para buscar)" \
        <<< "$emojis")

    echo "$chosen" | sed 's/\t.*$//'
}

copy_to_clipboard() {
    local emoji="$1"
    echo -n "$emoji" | xclip -selection clipboard
}

notify_user() {
    local emoji="$1"
    notify-send "Emoji copiado!" "$emoji" -i face-smile
}

main() {
    check_dependencies
    install_emoji_font
    
    local chosen=$(show_picker)
    chosen=$(echo "$chosen" | sed 's/\t.*$//; s/ *$//')
    
    [[ -z "$chosen" ]] && exit 0
    
    copy_to_clipboard "$chosen"
    notify_user "$chosen"
}

main "$@"
