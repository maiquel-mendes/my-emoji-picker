#!/usr/bin/env bash

# Emoji Picker for Linux
# Versão 1.2.0 - Correção de Busca (Nome e Categoria Simultâneos)

set -e

# Configurações
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -d "$HOME/.local/share/emoji-picker" ]; then
    DATA_DIR="$HOME/.local/share/emoji-picker"
else
    DATA_DIR="$SCRIPT_DIR/data"
fi

CACHE_DIR="$HOME/.cache/emoji-picker"
CACHE_FILE="$CACHE_DIR/emojis.cache"
VERSION="1.2.0"

cleanup() {
    pkill -u "$USER" -x yad 2>/dev/null || true
}

get_all_emojis() {
    local json_file="$DATA_DIR/emojis.json"
    
    if [ ! -f "$json_file" ]; then
        yad --error --text="Arquivo de emojis não encontrado."
        return 1
    fi

    if [ -f "$CACHE_FILE" ] && [ "$CACHE_FILE" -nt "$json_file" ]; then
        return 0
    fi

    mkdir -p "$CACHE_DIR"
    
    python3 -c "
import json
import sys
import html

try:
    with open('$json_file', 'r', encoding='utf-8') as f:
        data = json.load(f)
        with open('$CACHE_FILE', 'w', encoding='utf-8') as cache:
            # Ordenamos por categoria para a lista começar organizada
            for cat_key in sorted(data.keys()):
                cat_data = data[cat_key]
                cat_name = cat_data.get('name', cat_key)
                for item in cat_data.get('emojis', []):
                    emoji = item[0]
                    desc = item[1]
                    
                    # Col 1: Emoji (MARKUP)
                    cache.write(f'<span size=\"x-large\">{emoji}</span>\n')
                    # Col 2: Descrição
                    cache.write(f'{desc}\n')
                    # Col 3: Categoria
                    cache.write(f'{cat_name}\n')
                    # Col 4: Raw para Cópia (Escondido)
                    cache.write(f'{emoji}\n')
                    # Col 5: Super Índice de Busca (Escondido)
                    # Colocamos tudo aqui para que o filtro encontre em qualquer lugar
                    cache.write(f'{desc} {cat_name} {emoji}\n')
except Exception as e:
    sys.exit(1)
"
}

show_picker() {
    get_all_emojis
    
    # Única janela: Modo Lista (Tabela)
    # --search-column=5 garante que a busca funcione tanto por nome quanto por categoria
    local chosen
    chosen=$(yad --center \
        --title="Emoji Picker v$VERSION" \
        --width=650 --height=600 \
        --list \
        --column="Emoji":markup \
        --column="Descrição":TEXT \
        --column="Categoria":TEXT \
        --column="Raw":TEXT:hd \
        --column="Busca"TEXT \
        --print-column=4 \
        --hide-column=5 \
        --search-column=5 \
        --regex-search \
        --separator="" \
        --text="Busque por <b>Nome</b> ou <b>Categoria</b>. Clique nos cabeçalhos para ordenar." < "$CACHE_FILE")
    
    echo -n "$chosen"
}

copy_to_clipboard() {
    local emoji="$1"
    if [ -n "$emoji" ]; then
        echo -n "$emoji" | tr -d '\n\r' | xclip -selection clipboard
        return 0
    fi
    return 1
}

notify_user() {
    local emoji="$1"
    if [ -n "$emoji" ]; then
        notify-send "Emoji copiado!" "$emoji" -i face-smile &
    fi
}

main() {
    case "$1" in
        -v|--version) echo "v$VERSION"; exit 0 ;;
        --clear-cache) rm -f "$CACHE_FILE"; echo "Cache limpo."; exit 0 ;;
    esac

    local selected=$(show_picker)
    
    if [ -n "$selected" ]; then
        if copy_to_clipboard "$selected"; then
            notify_user "$selected"
        fi
    fi
    exit 0
}

trap cleanup EXIT

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
