# Emoji Picker para Linux

Seletor de emojis leve, rápido e elegante com atalho global para Linux. Abre um menu interativo baseado em YAD com busca instantânea, copiando o emoji escolhido diretamente para a sua área de transferência.

## 🚀 Recursos

- **Visual Premium**: Emojis em tamanho maior com suporte a Pango markup.
- **Performance Instantânea**: Sistema de cache em arquivo que carrega mais de 900 emojis em ~1ms.
- **Busca Inteligente**: Filtre por nome do emoji, descrição ou categoria em tempo real.
- **Atalhos Globais**: Configura automaticamente `Super+.` (igual ao Windows) ou `Ctrl+Alt+.`.
- **Notificações**: Feedback visual imediato ao copiar um emoji.
- **Instalação Automatizada**: Script que configura binários, dados, ícones e atalhos.

## 🛠️ Requisitos

- Linux com ambiente gráfico (GNOME, KDE, XFCE, etc.)
- **YAD** (Yet Another Dialog)
- **xclip** (Para manipulação da área de transferência)
- **libnotify** (Para notificações)
- **xbindkeys** (Para os atalhos globais)
- **Fonte Noto Color Emoji** (Para correta visualização dos emojis)

## 📦 Instalação

```bash
chmod +x install.sh
./install.sh
```

O instalador irá:
1. Verificar e instalar dependências via gerenciador de pacotes (`apt`, `dnf`, `pacman`, etc.)
2. Instalar o script em `~/.local/bin/`
3. Instalar o banco de dados de emojis em `~/.local/share/emoji-picker/`
4. Criar entrada no menu de aplicativos (XDG Desktop Entry)
5. Configurar e iniciar os atalhos globais via `xbindkeys`
6. Configurar a inicialização automática junto com o sistema

## 💡 Uso

1. Pressione `Super+.` ou `Ctrl+Alt+.` em qualquer aplicação.
2. Busque o emoji digitando no campo de pesquisa (ex: `fire`, `heart`, `beer`).
3. Selecione com as setas e pressione **Enter** ou clique no emoji.
4. O emoji será copiado. Cole com `Ctrl+V` onde desejar.

### Comandos de Terminal

```bash
emoji-picker.sh --help      # Mostra ajuda
emoji-picker.sh --version   # Mostra versão atual
emoji-picker.sh --clear-cache # Limpa o cache de emojis
```

## 🗑️ Desinstalação

```bash
chmod +x uninstall.sh
./uninstall.sh
```

## 📂 Estrutura do Projeto

```
my-emoji-picker/
├── emoji-picker.sh   # Script principal (Bash)
├── install.sh        # Script de instalação
├── uninstall.sh      # Script de desinstalação
├── data/             # Dados originais de emojis
├── tests/            # Suíte de testes automatizados
├── VERSION           # Versão atual do projeto
└── CHANGELOG.md      # Histórico de alterações
```

## 📝 Licença

Este projeto está sob a licença [MIT](LICENSE).
