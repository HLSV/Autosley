#!/bin/bash

# =====================================================================
# AUTOSLEY - Instalador Inteligente de Autocompletar para Zsh
# Versão: 0.0.1
# Criador: Igor
# 
# Este script automatiza a instalação completa do Zsh e do
# framework Oh My Zsh, incluindo plugins para autocompletar e
# navegação inteligente.
#
# Funciona em Kali Linux, Ubuntu, Termux e outros sistemas com apt/pkg.
# =====================================================================

# --- Cores para o terminal ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# --- Variáveis de Configuração ---
OH_MY_ZSH_REPO="https://github.com/ohmyzsh/ohmyzsh.git"
OH_MY_ZSH_PATH="$HOME/.oh-my-zsh"
ZSHRC_FILE="$HOME/.zshrc"
PLUGINS_PATH="$HOME/.oh-my-zsh/custom/plugins"

# --- Funções de Ajuda ---

# Verifica se um comando existe no sistema
function command_exists() {
    command -v "$1" &> /dev/null
}

# Habilita o Autosley no .zshrc
function enable_autosley() {
    # Remove configurações antigas para evitar duplicatas, incluindo linhas de source
    sed -i '/# -- Autosley (start) --/,/# -- Autosley (end) --/d' "$ZSHRC_FILE"
    sed -i '/^\s*source .*oh-my-zsh\.sh/d' "$ZSHRC_FILE"

    # Adiciona a nova configuração completa do Zsh e os plugins
    cat << EOF >> "$ZSHRC_FILE"

# -- Autosley (start) --
# Configuração do Autosley (Criado por Igor)

# Caminho para o Oh My Zsh
export ZSH="\$HOME/.oh-my-zsh"

# Tema para o terminal (robbyrussell é simples e funcional)
ZSH_THEME="robbyrussell"

# Lista de plugins
# zsh-autosuggestions: Sugere comandos em tempo real com base no histórico.
# zsh-completions: Fornece autocompletar para comandos e argumentos de programas instalados.
plugins=(git zsh-autosuggestions zsh-completions)

# Carrega o Oh My Zsh
source \$ZSH/oh-my-zsh.sh

# Configuração do prompt
PROMPT='%F{green}%n@%m%f:%F{cyan}%~%f\$ '

# Configuração para zsh-autosuggestions
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=244'
ZSH_AUTOSUGGEST_USE_HISTORY_BY_DEFAULT=true

# --- Lógica para o Comando Seta para a Direita ---
# Esta função verifica se há uma sugestão do autosuggestions.
# Se houver, ela aceita a sugestão.
# Se não houver, ela aciona o autocompletar para mostrar a lista de opções.
_autosley_complete_or_accept() {
  # zsh-autosuggestions armazena a sugestão na variável ZSH_AUTOSUGGEST_SUGGESTION.
  # Verificamos se essa variável está preenchida para saber se há uma sugestão.
  if [[ -n "\${ZSH_AUTOSUGGEST_SUGGESTION}" ]]; then
    autosuggest-accept
  else
    complete-word
  fi
}
# Vincula a tecla SETA PARA A DIREITA à nova função inteligente.
bindkey '^[[C' _autosley_complete_or_accept

# Mensagem de boas-vindas na inicialização do terminal
echo -e "\n${GREEN}============================================${NC}"
echo -e "${GREEN}  Autosley (v0.0.1) ativado. Criado por Igor.${NC}"
echo -e "${GREEN}============================================${NC}"
echo -e "${YELLOW}Aqui estão alguns exemplos de como usar a ferramenta:${NC}"
echo -e "${YELLOW}1. Comece a digitar um comando. Uma sugestão em cinza vai aparecer.${NC}"
echo -e "${YELLOW}   -> Pressione ${CYAN}SETA PARA A DIREITA${YELLOW} para aceitar a sugestão.${NC}"
echo -e "${YELLOW}2. Digite parte de um comando e pressione ${CYAN}SETA PARA A DIREITA${YELLOW} novamente.${NC}"
echo -e "${YELLOW}   -> O terminal mostrará uma lista de todas as opções de comando e argumentos instalados no seu sistema, mesmo que você nunca os tenha usado.${NC}"
echo -e "\n${YELLOW}Para desativar, use: ${RED}./autosley.sh disable${NC}"
echo -e "${YELLOW}Para ativar novamente, use: ${GREEN}./autosley.sh enable${NC}"
echo -e ""

# -- Autosley (end) --
EOF
    echo -e "${GREEN}[+] Autosley habilitado com sucesso. Reinicie o terminal para usar.${NC}"
}

# Desabilita o Autosley no .zshrc
function disable_autosley() {
    if grep -q "# -- Autosley (start) --" "$ZSHRC_FILE"; then
        sed -i '/# -- Autosley (start) --/,/# -- Autosley (end) --/d' "$ZSHRC_FILE"
        echo -e "${RED}[-] Autosley desabilitado. O terminal voltará ao seu estado padrão após o reinício.${NC}"
    else
        echo -e "${YELLOW}[-] Autosley já está desabilitado.${NC}"
    fi
}

# Desinstala o Autosley completamente, removendo os arquivos de plugins
function uninstall_autosley() {
    echo -e "${YELLOW}[!] Desinstalando o Autosley...${NC}"
    
    # Desabilita o Autosley no .zshrc primeiro e remove qualquer linha de source
    disable_autosley
    sed -i '/^\s*source .*oh-my-zsh\.sh/d' "$ZSHRC_FILE"

    # Remove o diretório do Oh My Zsh para uma limpeza completa
    if [ -d "$OH_MY_ZSH_PATH" ]; then
        echo -e "${YELLOW}[!] Removendo Oh My Zsh e plugins antigos...${NC}"
        rm -rf "$OH_MY_ZSH_PATH"
        echo -e "${GREEN}[+] Oh My Zsh e plugins removidos com sucesso.${NC}"
    fi
    
    echo -e "${GREEN}[+] Desinstalação do Autosley concluída. O terminal está limpo.${NC}"
}

# --- Função Principal de Instalação ---
function install_autosley() {
    echo -e "${CYAN}===========================================${NC}"
    echo -e "${CYAN}        Bem-vindo ao Autosley v0.0.1        ${NC}"
    echo -e "${CYAN}           (Criado por Igor)               ${NC}"
    echo -e "${CYAN}===========================================${NC}"

    # Etapa 0: Desativar e desinstalar versões antigas para evitar conflitos
    echo -e "${YELLOW}[!] Verificando e desinstalando versões antigas do Autosley...${NC}"
    uninstall_autosley

    # Etapa 1: Identificar o sistema de gerenciamento de pacotes
    local install_cmd=""
    local system_name=""
    if command_exists "pkg"; then
        install_cmd="pkg install"
        system_name="Termux"
    elif command_exists "apt"; then
        install_cmd="apt install"
        system_name="Linux (Debian/Ubuntu/Kali)"
        if command_exists "sudo"; then
            install_cmd="sudo $install_cmd"
        fi
    else
        echo -e "${RED}[-] Gerenciador de pacotes não suportado. Este script funciona com 'apt' ou 'pkg'.${NC}"
        exit 1
    fi
    echo -e "${CYAN}[!] Sistema detectado: ${system_name}${NC}"

    # Etapa 2: Instalar Zsh e Git
    echo -e "${YELLOW}[!] Verificando e instalando dependências (Zsh, Git)...${NC}"
    
    if ! command_exists "zsh"; then
        $install_cmd zsh -y
        if [ $? -ne 0 ]; then
            echo -e "${RED}[-] Erro ao instalar Zsh. Verifique sua conexão.${NC}"
            exit 1
        fi
    fi

    if ! command_exists "git"; then
        $install_cmd git -y
        if [ $? -ne 0 ]; then
            echo -e "${RED}[-] Erro ao instalar Git. Verifique sua conexão.${NC}"
            exit 1
        fi
    fi
    echo -e "${GREEN}[+] Dependências instaladas com sucesso.${NC}"

    # Etapa 3: Instalar Oh My Zsh
    if [ ! -d "$OH_MY_ZSH_PATH" ]; then
        echo -e "${YELLOW}[!] Clonando o repositório Oh My Zsh...${NC}"
        git clone "$OH_MY_ZSH_REPO" "$OH_MY_ZSH_PATH"
        if [ $? -ne 0 ]; then
            echo -e "${RED}[-] Erro ao clonar o Oh My Zsh. Verifique sua conexão.${NC}"
            exit 1
        fi
    else
        echo -e "${YELLOW}[-] Oh My Zsh já está instalado. Prosseguindo com a configuração.${NC}"
    fi

    # Etapa 4: Instalar os plugins
    local plugins_to_install=(
        "https://github.com/zsh-users/zsh-autosuggestions.git"
        "https://github.com/zsh-users/zsh-completions.git"
    )
    for repo in "${plugins_to_install[@]}"; do
        plugin_name=$(basename "$repo" .git)
        echo -e "${YELLOW}[!] Instalando plugin '$plugin_name'...${NC}"
        git clone "$repo" "$PLUGINS_PATH/$plugin_name"
        if [ $? -ne 0 ]; then
            echo -e "${RED}[-] Erro ao instalar o plugin '$plugin_name'. Verifique sua conexão.${NC}"
            exit 1
        fi
    done

    # Etapa 5: Configurar o arquivo .zshrc
    echo -e "${YELLOW}[!] Configurando o arquivo .zshrc...${NC}"

    # Cria uma cópia de segurança
    if [ -f "$ZSHRC_FILE" ]; then
        cp "$ZSHRC_FILE" "${ZSHRC_FILE}.bak"
    fi
    
    enable_autosley
    
    echo ""
    echo -e "${GREEN}===========================================${NC}"
    echo -e "${GREEN}Instalação do Autosley concluída com sucesso!${NC}"
    echo -e "${GREEN}Para usar a ferramenta, mude seu shell padrão para Zsh:${NC}"
    echo -e "${YELLOW}  chsh -s zsh${NC}"
    echo -e "${GREEN}Em seguida, feche e abra o terminal. ${NC}"
    echo -e "${GREEN}===========================================${NC}"
}

# --- Ponto de Entrada do Script ---
case "$1" in
    install)
        install_autosley
        ;;
    enable)
        enable_autosley
        ;;
    disable)
        disable_autosley
        ;;
    uninstall)
        uninstall_autosley
        ;;
    *)
        echo -e "${RED}[-] Comando inválido. Use './autosley.sh install', './autosley.sh enable', './autosley.sh disable' ou './autosley.sh uninstall'${NC}"
        ;;
esac
