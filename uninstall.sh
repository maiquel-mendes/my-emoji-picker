#!/usr/bin/env bash

# ===============================================
# uninstall.sh
# Remove o Emoji Picker e configurações
# ===============================================

set -e

INSTALL_DIR="$HOME/.local/bin"
DESKTOP_FILE="$HOME/.local/share/applications/emoji-picker.desktop"
AUTOSTART_FILE="$HOME/.config/autostart/emoji-picker.desktop"
XKBINDKEYSRC="$HOME/.xbindkeysrc"

echo "=========================================="
echo "  Emoji Picker - Desinstalação"
echo "=========================================="

echo "[1/4] Removendo script..."
if [ -f "$INSTALL_DIR/emoji-picker.sh" ]; then
    rm -f "$INSTALL_DIR/emoji-picker.sh"
    echo "  Script removido."
else
    echo "  Script não encontrado."
fi

echo "[2/4] Removendo entrada no menu..."
if [ -f "$DESKTOP_FILE" ]; then
    rm -f "$DESKTOP_FILE"
    echo "  Entrada removida."
else
    echo "  Entrada não encontrada."
fi

echo "[3/4] Removendo atalho global..."
if [ -f "$XKBINDKEYSRC" ]; then
    sed -i '/Emoji Picker/,/^$/d' "$XKBINDKEYSRC"
    sed -i '/^$/N;/^\n$/d' "$XKBINDKEYSRC"
    echo "  Configuração de atalho removida."
fi

pkill -x xbindkeys 2>/dev/null || true

echo "[4/4] Removendo inicialização automática..."
if [ -f "$AUTOSTART_FILE" ]; then
    rm -f "$AUTOSTART_FILE"
    echo "  Autostart removido."
else
    echo "  Autostart não encontrado."
fi

echo ""
echo "=========================================="
echo "  Desinstalação concluída!"
echo "=========================================="
echo ""
echo "As dependências (yad, xclip, etc.) foram mantidas."
echo "Se quiser remover, use o gerenciador de pacotes."
