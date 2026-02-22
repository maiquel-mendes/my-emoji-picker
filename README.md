# Emoji Picker para Linux

Seletor de emojis via atalho global para Linux. Abre um menu interativo com busca para escolher emojis, que são copiados para a área de transferência.

## Recursos

- Seletor de emojis com busca em tempo real
- Atalhos globais: `Super+.` ou `Ctrl+Alt+.`
- Notificação ao copiar emoji
- Instalação automática de dependências
- Suporte às principais distribuições Linux

## Requisitos

- Linux com ambiente gráfico (GNOME, KDE, XFCE, etc.)
- YAD (Yet Another Dialog)
- xclip
- libnotify
- xbindkeys
- Fonte Noto Color Emoji

## Instalação

```bash
chmod +x install.sh
./install.sh
```

O instalador irá:
1. Verificar e instalar dependências
2. Copiar o script para `~/.local/bin/`
3. Criar entrada no menu de aplicativos
4. Configurar atalho global via xbindkeys
5. Configurar inicialização automática

## Uso

1. Pressione `Super+.` ou `Ctrl+Alt+.` em qualquer aplicação
2. Busque o emoji digitando no campo de pesquisa
3. Clique no emoji desejado ou selecione com Enter
4. O emoji será copiado para a área de transferência
5. Cole com `Ctrl+V` onde desejar

## Desinstalação

```bash
chmod +x uninstall.sh
./uninstall.sh
```

## Solução de Problemas

### O atalho não funciona
- Reinicie a sessão ou faça logout/login
- Verifique se xbindkeys está em execução: `pgrep xbindkeys`
- Inicie manualmente: `xbindkeys`

### Os emojis aparecem como quadrado
- A fonte Noto Color Emoji não está instalada
- Instale manualmente:
  - **Ubuntu/Debian**: `sudo apt install fonts-noto-color-emoji`
  - **Fedora**: `sudo dnf install google-noto-color-emoji-fonts`
  - **Arch**: `sudo pacman -S noto-fonts-emoji`

### Menu não abre
- Verifique se yad está instalado: `which yad`
- Execute o script manualmente para ver erros: `~/.local/bin/emoji-picker.sh`

## Estrutura do Projeto

```
my-emoji-picker/
├── emoji-picker.sh   # Script principal
├── install.sh        # Script de instalação
├── uninstall.sh      # Script de desinstalação
└── README.md         # Este arquivo
```

## Licença

MIT
