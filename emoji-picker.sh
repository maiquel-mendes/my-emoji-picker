#!/usr/bin/env bash

# Emoji Picker for Linux
# Author: Antigravity

set -e

# Configurações
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Se estiver instalado em ~/.local/bin, procura em ~/.local/share/emoji-picker
# Caso contrário (desenvolvimento), usa a pasta data local
if [ -d "$HOME/.local/share/emoji-picker" ]; then
    DATA_DIR="$HOME/.local/share/emoji-picker"
else
    DATA_DIR="$SCRIPT_DIR/data"
fi

CACHE_DIR="$HOME/.cache/emoji-picker"
CACHE_FILE="$CACHE_DIR/emojis.cache"
LOG_FILE="$HOME/.local/share/emoji-picker.log"

VERSION="1.0.0"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE" 2>/dev/null || true
}

show_help() {
    echo "Emoji Picker v$VERSION"
    echo "Uso: $(basename "$0") [opções]"
    echo ""
    echo "Opções:"
    echo "  -v, --version    Mostra a versão"
    echo "  -h, --help       Mostra esta ajuda"
    echo "  --clear-cache    Limpa o cache de emojis"
}

# Processar argumentos
case "$1" in
    -v|--version)
        echo "v$VERSION"
        exit 0
        ;;
    -h|--help)
        show_help
        exit 0
        ;;
    --clear-cache)
        rm -f "$CACHE_FILE"
        echo "Cache limpo."
        exit 0
        ;;
esac

# Limpa processos órfãos do yad se houver
cleanup() {
    pkill -u "$USER" -x yad 2>/dev/null || true
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
            sudo apt-get install -y "${missing[@]}" libnotify-bin
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y "${missing[@]}" libnotify
        elif command -v pacman &>/dev/null; then
            sudo pacman -S --noconfirm "${missing[@]}" libnotify
        fi
    fi
}

install_emoji_font() {
    if ! fc-list | grep -qi "Noto Color Emoji"; then
        log "Tentando instalar fonte Noto Color Emoji..."
        if command -v apt-get &>/dev/null; then
            sudo apt-get install -y fonts-noto-color-emoji
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y google-noto-color-emoji-fonts
        elif command -v pacman &>/dev/null; then
            sudo pacman -S --noconfirm noto-fonts-emoji
        fi
        fc-cache -f -v 2>/dev/null || true
    fi
}

get_all_emojis() {
    local json_file="$DATA_DIR/emojis.json"
    
    if [ ! -f "$json_file" ]; then
        yad --error --text="Arquivo de emojis não encontrado."
        return 1
    fi

    # Se o arquivo de cache já processado existe e é mais novo
    if [ -f "$CACHE_FILE" ] && [ "$CACHE_FILE" -nt "$json_file" ]; then
        return 0
    fi

    mkdir -p "$CACHE_DIR"
    
    # Gera o cache no formato que o YAD entende (um campo por linha)
    python3 -c "
import json
import sys
import html

try:
    with open('$json_file', 'r', encoding='utf-8') as f:
        data = json.load(f)
        with open('$CACHE_FILE', 'w', encoding='utf-8') as cache:
            for cat_key, cat_data in data.items():
                cat_name = cat_data.get('name', cat_key)
                for item in cat_data.get('emojis', []):
                    emoji = item[0]
                    desc = item[1]
                    cat = cat_name
                    
                    # Col 1: Display
                    display = f'<span size=\"x-large\">{emoji}</span>  {html.escape(desc)} <span size=\"small\" alpha=\"50%\">({html.escape(cat)})</span>\n'
                    # Col 2: Raw
                    raw = f'{emoji}\n'
                    # Col 3: Search
                    search = f'{desc} {cat}\n'
                    
                    cache.write(display)
                    cache.write(raw)
                    cache.write(search)
except Exception as e:
    sys.exit(1)
"
}

show_picker() {
    # Garantimos que o cache existe
    get_all_emojis
    
    # Executamos o YAD lendo diretamente do arquivo de cache para evitar pipes pesados
    # Usamos o separador de linha para as colunas
    local chosen
    chosen=$(yad --center \
        --title="Emoji Picker" \
        --width=500 --height=600 \
        --list \
        --column="Emoji e Descrição":markup \
        --column="Raw":TEXT \
        --column="Search":TEXT \
        --hide-column=2 --hide-column=3 \
        --print-column=2 \
        --search-column=3 \
        --separator="" \
        --no-headers \
        --text="Busque seu emoji (ex: heart, coffee...)" < "$CACHE_FILE")
    
    # Retorna o que foi escolhido (puro)
    echo -n "$chosen"
}

copy_to_clipboard() {
    local emoji="$1"
    if [ -n "$emoji" ]; then
        # Remove qualquer newline que o yad possa ter retornado antes de enviar ao xclip
        echo -n "$emoji" | tr -d '\n\r' | xclip -selection clipboard
        return 0
    fi
    return 1
}

notify_user() {
    local emoji="$1"
    if [ -n "$emoji" ]; then
        # Executa em background para não travar o processo principal
        notify-send "Emoji copiado!" "$emoji" -i face-smile &
    fi
}

main() {
    check_dependencies
    install_emoji_font
    
    # Captura a seleção
    local selected
    selected=$(show_picker)
    
    # Se cancelou (selected vazio), sai limpo
    if [ -z "$selected" ]; then
        exit 0
    fi

    # Copia e notifica
    if copy_to_clipboard "$selected"; then
        notify_user "$selected"
    fi
    
    # Garante saída imediata
    exit 0
}

# Trap para limpar ao sair
trap cleanup EXIT

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
