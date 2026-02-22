#!/usr/bin/env bash

# ===============================================
# emoji-picker.sh
# Atalho global → abre menu YAD com emojis coloridos
# Insere o emoji escolhido onde o cursor está
# ===============================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$HOME/.local/share/emoji-picker.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE" 2>/dev/null || true
}

check_dependencies() {
    local missing=()
    
    for cmd in yad xclip notify-send; do
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

check_dependencies
install_emoji_font

# Lista bem grande de emojis (pode expandir bastante)
# Formato:   emoji    descrição curta
emojis=$(cat <<'EOF'
😀 rosto_rindo
😁 rosto_risonho_com_olhos_sorrindo
😂 rosto_com_lágrimas_de_alegria
🤣 rolando_de_rir
😃 rosto_sorridente_com_olhos_grandes
😄 rosto_muito_sorridente_com_olhos_sorrindo
😅 rosto_sorridente_com_suor
😆 rosto_rindo_com_olhos_fechados
😉 rosto_piscando
😊 rosto_sorridente_com_olhos_sorrindo
😋 rosto_saboreando_comida
😎 rosto_com_óculos_de_sol
😍 rosto_com_olhos_de_coração
😘 rosto_beijando_com_olhos_fechados
🥰 rosto_com_olhos_de_coração_e_rosto_vermelho
😗 rosto_beijando
😙 rosto_beijando_com_olhos_sorrindo
😚 rosto_beijando_com_olhos_fechados
☺️ rosto_sorridente
🙂 rosto_sorridente_leve
🤗 rosto_abraçando
🤩 rosto_estrela
🤔 rosto_pensando
🫡 rosto_saudando
🤨 rosto_com_sobrancelha_levantada
😐 rosto_neutro
😑 rosto_sem_expressão
😶 rosto_sem_boca
🫥 rosto_pontilhado
😶‍🌫️ rosto_nas_nuvens
😏 rosto_sorrateiro
😣 rosto_perseverante
😥 rosto_triste_com_suor
😮 rosto_com_boca_aberta
🤐 rosto_com_boca_fechada_com_zíper
😯 rosto_surpreso_silencioso
😪 rosto_sonolento
😫 rosto_cansado
🥱 rosto_bochando
😴 rosto_dormindo
😌 rosto_aliviado
😛 rosto_com_língua
😜 rosto_piscando_com_língua
🤪 rosto_louco
😝 rosto_com_olhos_cruzados_e_língua
🤤 rosto_babando
😒 rosto_com_olhar_desinteressado
😓 rosto_com_suor_frio
😔 rosto_pensativo
😕 rosto_confuso
🫤 rosto_com_diagonal_boca
😖 rosto_confuso_com_boca_aberta
🙄 rosto_revirando_os_olhos
😞 rosto_decepcionado
😟 rosto_preocupado
😤 rosto_com_vapor_do_nariz
😢 rosto_chorando
😭 rosto_chorando_alto
😦 rosto_aberto_com_sobrancelhas_franzidas
😧 rosto_angustiado
😨 rosto_com medo
😩 rosto_cansado
🤯 rosto_explodindo
😬 rosto_com_caretas
😮‍💨 rosto_exalando
😯 rosto_surpreso
🥳 rosto_festejando
🥸 rosto_disfarçado
😎 rosto_com_óculos_de_sol
🤓 nerd
🧐 rosto_com_monóculo
🤠 rosto_de_caubói
😡 rosto_ bravo
🤬 rosto_com_símbolos_na_boca
😷 rosto_com_máscara_médica
🤒 rosto_com_termômetro
🤕 rosto_com_curativo
🤑 rosto_com_dinheiro
🤥 rosto_mentiroso
😈 sorriso_maligno
👿 diabinho
💀 caveira
☠️ caveira_e_ossos_cruzados
💩 cocô
🤡 palhaço
👻 fantasma
👽 alienígena
👾 monstro_alienígena
🤖 robô
😺 gato_sorrindo
😸 gato_sorrindo_com_olhos_sorrindo
😹 gato_com_lágrimas_de_alegria
😻 gato_com_olhos_de_coração
😼 gato_com_sorriso_irônico
😽 gato_beijando
🙀 gato_surpreso
😿 gato_chorando
😾 gato_mal-humorado
🙈 macaco_não_vejo
🙉 macaco_não_ouço
🙊 macaco_não_falo
❤️ coração_vermelho
🧡 coração_laranja
💛 coração_amarelo
💚 coração_verde
💙 coração_azul
💜 coração_roxo
🖤 coração_preto
🤍 coração_branco
🤎 coração_marrom
🩷 coração_rosa
🩵 coração_azul_claro
🩶 coração_cinza
❤️‍🔥 coração_em_chamas
❤️‍🩹 coração_remendado
💔 coração_partido
💕 dois_corações
💞 corações_girando
💓 coração_batendo
💗 coração_crescendo
💖 coração_brilhante
💘 coração_com_flecha
💝 coração_com_laço
🫀 órgão_coração
🫁 pulmões
🧠 cérebro
🦷 dente
🦴 osso
👀 olhos
👁️ olho
🫦 boca_mordendo_lábio
👄 boca
🫃 homem_grávido
🫄 pessoa_grávida
🧑‍🍼 pessoa_alimentando_bebê
👶 bebê
🧒 criança
👦 menino
👧 menina
🧑 adulto
👱 pessoa_cabelo_loiro
👨 homem
🧔 pessoa_com_barba
👩 mulher
🧓 idoso
👴 idoso
👵 idosa
🙍 pessoa_franzindo_a_testa
🙎 pessoa_birrentando
🙅 pessoa_fazendo_gesto_de_não
🙆 pessoa_fazendo_gesto_de_ok
💁 pessoa_levantando_mão
🙋 pessoa_levantando_a_mão
🧏 pessoa_surda
🙇 pessoa_se_curvando
🤦 pessoa_facepalming
🤷 pessoa_dando_de_ombros
🧑‍⚕️ profissional_de_saúde
👨‍⚕️ homem_profissional_de_saúde
👩‍⚕️ mulher_profissional_de_saúde
🧑‍🎓 estudante
👨‍🎓 homem_estudante
👩‍🎓 mulher_estudante
🧑‍🏫 professor
👨‍🏫 homem_professor
👩‍🏫 mulher_professor
🧑‍⚖️ juiz
👨‍⚖️ homem_juiz
👩‍⚖️ mulher_juiz
🧑‍🌾 agricultor
👨‍🌾 homem_agricultor
👩‍🌾 mulher_agricultora
🧑‍🍳 cozinheiro
👨‍🍳 homem_cozinheiro
👩‍🍳 mulher_cozinheira
🧑‍🔧 mecânico
👨‍🔧 homem_mecânico
👩‍🔧 mulher_mecânica
🧑‍🏭 trabalhador_fábrica
👨‍🏭 homem_trabalhador_fábrica
👩‍🏭 mulher_trabalhadora_fábrica
🧑‍💼 trabalhador_escritório
👨‍💼 homem_trabalhador_escritório
👩‍💼 mulher_trabalhadora_escritório
🧑‍🔬 cientista
👨‍🔬 homem_cientista
👩‍🔬 mulher_cientista
🧑‍💻 technologist
👨‍💻 homem_technologist
👩‍💻 mulher_technologist
🧑‍🎤 cantor
👨‍🎤 homem_cantor
👩‍🎤 mulher_cantora
🧑‍🎨 artista
👨‍🎨 homem_artista
👩‍🎨 mulher_artista
🧑‍✈️ piloto
👨‍✈️ homem_piloto
👩‍✈️ mulher_piloto
🧑‍🚀 astronauta
👨‍🚀 homem_astronauta
👩‍🚀 mulher_astronauta
🧑‍🚒 bombeiro
👨‍🚒 homem_bombeiro
👩‍🚒 mulher_bombeira
👮 policial
👷 trabalhador_construção
💂 guarda
🕵️ detetive
🫅 pessoa_com_coroa
👑 coroa
🪙 moeda
💰 bolsa_de_dinheiro
💴 nota_de_iene
💵 nota_de_dólar
💶 nota_de_euro
💷 nota_de_libra
💸 dinheiro_voando
💳 cartão_de_crédito
🧾 recibo
💹 gráfico_subindo_com_iene
✉️ envelope
📧 e-mail
📨 envelope_recebendo
📩 envelope_com_seta
📤 bandeja_de_saída
📥 bandeja_de_entrada
📦 pacote
📫 caixa_de_correio_fechada_com_bandeira_levantada
📪 caixa_de_correio_fechada_com_bandeira_abaixada
📬 caixa_de_correio_aberta_com_bandeira_levantada
📭 caixa_de_correio_aberta_com_bandeira_abaixada
📮 caixa_de_correio
🗳️ urna_com_voto
✏️ lápis
✒️ caneta_tinteiro
🖋️ caneta
🖊️ caneta_esferográfica
🖌️ pincel
🖍️ giz_de_cera
📝 memorando
💼 pasta
📁 pasta_arquivos
📂 pasta_aberta
🗂️ divisor_de_cartões
📅 calendário
📆 calendário_destacável
🗒️ bloco_de_notas_com_espiral
🗓️ calendário_com_espiral
📇 cartão_de_índice
📈 gráfico_subindo
📉 gráfico_descendo
📊 gráfico_de_barras
📋 prancheta
📌 tachinha
📍 alfinete_redondo
📎 clipe_de_papel
🖇️ clipes_de_papel_conectados
📏 régua_reta
📐 régua_triangular
✂️ tesoura
🗃️ caixa_de_arquivos
🗄️ armário_de_arquivos
🗑️ lixeira
🔒 cadeado_fechado
🔓 cadeado_aberto
🔏 cadeado_com_caneta
🔐 cadeado_fechado_com_chave
🔑 chave
🗝️ chave_antiga
🔨 martelo
🪓 machado
⛏️ picareta
⚒️ martelo_e_picareta
🛠️ martelo_e_chave_inglesa
🗡️ adaga
⚔️ espadas_cruzadas
🔫 pistola
🪃 bumerangue
🏹 arco_e_flecha
🛡️ escudo
🪚 serra_de_carpinteiro
🔧 chave_inglesa
🪛 chave_de_fenda
🔩 porca_e_parafuso
⚙️ engrenagem
🗜️ clamp
⚖️ balança
🦯 bengala_branca
🔗 elo
⛓️ correntes
🪝 gancho
🧰 caixa_de_ferramentas
🧲 ímã
🪜 escada
⚗️ alambique
🧪 tubo_de_ensaio
🧫 placa_de_petri
🧬 dna
🔬 microscópio
🔭 telescópio
📡 antena_de_satélite
💉 seringa
🩸 gota_de_sangue
💊 pílula
🩹 curativo_adesivo
🩼 muleta
🩺 estetoscópio
🩻 raio-x
🚪 porta
🛗 elevador
🪞 espelho
🪟 janela
🛏️ cama
🛋️ sofá_e_lâmpada
🪑 cadeira
🚽 vaso_sanitário
🪠 desentupidor
🚿 chuveiro
🛁 banheira
🪤 ratoeira
🪒 navalha
🪣 balde
🧴 frasco_de_loção
🧷 alfinete_de_segurança
🧹 vassoura
🧺 cesta
🧻 rolo_de_papel
🪣 balde
🧼 sabão
🫧 bolhas
🪥 escova_de_dentes
🧽 esponja
🧯 extintor
🛒 carrinho_de_compras
🚬 cigarro
🪦 lápide
🧿 olho_grego
🪬 mão_de_fátima
🪪 cartão_de_identificação
🩻 raio-x
EOF
)

# -----------------------------------------------
# Cria lista formatada para o YAD (colunas: emoji | descrição)
# -----------------------------------------------
lista=$(echo "$emojis" | sed 's/ /|/')

# -----------------------------------------------
# Mostra o diálogo (busca habilitada, ícones grandes)
# -----------------------------------------------
escolhido=$(yad --center \
    --title="Emoji Picker" \
    --width=780 --height=580 \
    --list --column="Emoji":TEXT --column="Descrição" \
    --search-column=2 --print-column=1 \
    --separator="" --no-headers \
    --text="Selecione um emoji (comece a digitar para buscar)" \
    <<< "$lista")

# Remove possíveis caracteres extras do YAD
escolhido=$(echo "$escolhido" | sed 's/|.*$//; s/ *$//')

# Se cancelou ou fechou → sai
[[ -z "$escolhido" ]] && exit 0

# Copia o emoji para a área de transferência
echo -n "$escolhido" | xclip -selection clipboard

# Notificação opcional
notify-send "Emoji copiado!" "$escolhido" -i face-smile

exit 0
