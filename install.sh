#!/usr/bin/env bash

# ===============================================
# install.sh
# Instala o Emoji Picker e configura atalho global
# ===============================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EMOJI_SCRIPT="$SCRIPT_DIR/emoji-picker.sh"
INSTALL_DIR="$HOME/.local/bin"
DESKTOP_FILE="$HOME/.local/share/applications/emoji-picker.desktop"
AUTOSTART_FILE="$HOME/.config/autostart/emoji-picker.desktop"

echo "=========================================="
echo "  Emoji Picker - Instalação"
echo "=========================================="

install_dependencies() {
    echo "[1/5] Verificando dependências..."
    
    local deps=("yad" "xclip" "libnotify-bin" "xbindkeys")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "${dep}" &>/dev/null && [ "$dep" != "xbindkeys" ]; then
            missing+=("$dep")
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        echo "Instalando dependências: ${missing[*]}"
        
        if command -v apt-get &>/dev/null; then
            sudo apt-get update && sudo apt-get install -y "${missing[@]}" fonts-noto-color-emoji xbindkeys
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y "${missing[@]}" google-noto-color-emoji-fonts xbindkeys
        elif command -v pacman &>/dev/null; then
            sudo pacman -S --noconfirm "${missing[@]}" noto-fonts-emoji xbindkeys
        elif command -v zypper &>/dev/null; then
            sudo zypper install -y "${missing[@]}" google-noto-color-emoji-fonts xbindkeys
        else
            echo "ERRO: Não foi possível detectar o gerenciador de pacotes."
            echo "Instale manualmente: yad, xclip, libnotify-bin, xbindkeys, fonts-noto-color-emoji"
            exit 1
        fi
    else
        echo "  Todas as dependências já estão instaladas."
    fi
    
    if ! fc-list | grep -qi "Noto Color Emoji"; then
        echo "  Instalando fonte emoji..."
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

install_script() {
    echo "[2/5] Instalando script..."
    
    mkdir -p "$INSTALL_DIR"
    cp "$EMOJI_SCRIPT" "$INSTALL_DIR/emoji-picker.sh"
    chmod +x "$INSTALL_DIR/emoji-picker.sh"
    
    echo "  Script instalado em: $INSTALL_DIR/emoji-picker.sh"
}

create_desktop_entry() {
    echo "[3/5] Criando entrada no menu..."
    
    mkdir -p "$(dirname "$DESKTOP_FILE")"
    
    cat > "$DESKTOP_FILE" << 'EOF'
[Desktop Entry]
Name=Emoji Picker
Comment=Selecione emojis para copiar para a área de transferência
Exec=/home/maiquel/.local/bin/emoji-picker.sh
Icon=face-smile
Terminal=false
Type=Application
Categories=Utility;
EOF
    
    sed -i "s|/home/maiquel/|$HOME/|g" "$DESKTOP_FILE"
    
    echo "  Entrada criada em: $DESKTOP_FILE"
}

configure_shortcut() {
    echo "[4/5] Configurando atalho global..."
    
    XKBINDKEYSRC="$HOME/.xbindkeysrc"
    
    if [ ! -f "$XKBINDKEYSRC" ]; then
        xbindkeys --defaults > "$XKBINDKEYSRC"
    fi
    
    if ! grep -q "emoji-picker" "$XKBINDKEYSRC" 2>/dev/null; then
        cat >> "$XKBINDKEYSRC" << EOF

# Emoji Picker - Atalho Global (Super+. ou Ctrl+Alt+.)
"$INSTALL_DIR/emoji-picker.sh"
    Mod4 + period
    Control + Alt + period
EOF
    fi
    
    pkill -x xbindkeys 2>/dev/null || true
    sleep 0.5
    xbindkeys &
    echo "  xbindkeys iniciado."
    
    echo "  Atalho configurado: Super+. ou Ctrl+Alt+."
}

configure_autostart() {
    echo "[5/5] Configurando inicialização automática..."
    
    mkdir -p "$(dirname "$AUTOSTART_FILE")"
    
    cat > "$AUTOSTART_FILE" << 'EOF'
[Desktop Entry]
Type=Application
Name=Emoji Picker
Exec=xbindkeys
Comment=Atalho global para selecionar emojis
EOF
    
    echo "  Inicialização automática configurada."
}

main() {
    install_dependencies
    install_script
    create_desktop_entry
    configure_shortcut
    configure_autostart
    
    echo ""
    echo "=========================================="
    echo "  Instalação concluída!"
    echo "=========================================="
    echo ""
    echo "Atalho configurado:"
    echo "  • Super + ."
    echo "  • Ctrl + Alt + ."
    echo ""
    echo "O emoji será copiado para a área de transferência."
    echo "Use Ctrl+V para colar onde quiser!"
    echo ""
    echo "Para testar agora, execute:"
    echo "  $INSTALL_DIR/emoji-picker.sh"
    echo ""
    echo "Reinicie a sessão para o atalho funcionar completamente."
}

main
