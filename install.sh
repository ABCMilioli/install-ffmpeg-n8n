#!/bin/bash

# Verificar se está rodando como root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${vermelho}Este script precisa ser executado como root${reset}"
    echo -e "${amarelo}Use: sudo bash install.sh${reset}"
    exit 1
fi

# Cores para output
verde="\e[32m"
vermelho="\e[31m"
amarelo="\e[33m"
azul="\e[34m"
roxo="\e[35m"
reset="\e[0m"

# Banner
echo -e "\n    Automação de Baixo Custo  |  Instalador FFmpeg para n8n  |  Criado por Robson Milioli\n"

# Função para listar containers n8n
listar_containers() {
    echo -e "${azul}Containers n8n disponíveis:${reset}"
    docker ps --format "{{.Names}}" | grep n8n | nl
    echo ""
}

# Função para instalar FFmpeg
instalar_ffmpeg() {
    local container_id=$1
    echo -e "${azul}Iniciando instalação do FFmpeg no container $container_id...${reset}"
    
    # Instala as dependências
    echo -e "${amarelo}Instalando dependências...${reset}"
    docker exec $container_id apk add --no-cache --update python3 py3-pip gcc python3-dev musl-dev curl ffmpeg
    
    if [ $? -eq 0 ]; then
        echo -e "${verde}Instalação concluída com sucesso!${reset}"
        echo -e "${amarelo}Para verificar a instalação, você pode executar:${reset}"
        echo -e "docker exec $container_id ffmpeg -version"
    else
        echo -e "${vermelho}Erro durante a instalação. Verifique os logs acima para mais detalhes.${reset}"
    fi
}

# Lista os containers disponíveis
listar_containers

# Verifica se existem containers n8n
if ! docker ps --format "{{.Names}}" | grep -q n8n; then
    echo -e "${vermelho}Nenhum container n8n encontrado!${reset}"
    echo -e "${amarelo}Certifique-se de que o stack n8n está em execução:${reset}"
    echo -e "${verde}docker stack deploy -c docker-compose.yml n8n${reset}"
    echo -e "${amarelo}Deseja sair? (s/n)${reset}"
    read -p "> " sair
    if [[ "$sair" =~ ^[Ss]$ ]]; then
        echo -e "${amarelo}Saindo...${reset}"
        exit 0
    fi
fi

# Pede ao usuário para selecionar o container
echo -e "${amarelo}Digite o número do container onde deseja instalar o FFmpeg (ou 'q' para sair):${reset}"
if [ -t 0 ]; then
    read -p "> " opcao
else
    if [ -e /dev/tty ]; then
        read -p "> " opcao < /dev/tty
    else
        echo -e "${amarelo}Por favor, execute o script diretamente:${reset}"
        echo -e "${verde}sudo bash install.sh${reset}"
        exit 1
    fi
fi

# Verifica se o usuário quer sair
if [[ "$opcao" =~ ^[Qq]$ ]]; then
    echo -e "${amarelo}Saindo...${reset}"
    exit 0
fi

# Validação da entrada
if ! [[ "$opcao" =~ ^[0-9]+$ ]]; then
    echo -e "${vermelho}Opção inválida! Digite um número válido ou 'q' para sair.${reset}"
    exit 1
fi

# Obtém o nome do container selecionado
container_name=$(docker ps --format "{{.Names}}" | grep n8n | sed -n "${opcao}p")

if [ -z "$container_name" ]; then
    echo -e "${vermelho}Container não encontrado!${reset}"
    echo -e "${amarelo}Deseja tentar novamente? (s/n)${reset}"
    read -p "> " tentar_novamente
    if [[ "$tentar_novamente" =~ ^[Nn]$ ]]; then
        echo -e "${amarelo}Saindo...${reset}"
        exit 0
    fi
fi

# Obtém o ID do container
container_id=$(docker ps -q -f name=$container_name)

# Confirma a instalação
echo -e "${amarelo}Você selecionou o container: $container_name${reset}"
echo -e "${amarelo}Deseja instalar o FFmpeg neste container? (s/n)${reset}"
if [ -t 0 ]; then
    read -p "> " confirmacao
else
    if [ -e /dev/tty ]; then
        read -p "> " confirmacao < /dev/tty
    else
        confirmacao="n"
    fi
fi

if [[ "$confirmacao" =~ ^[Ss]$ ]]; then
    instalar_ffmpeg $container_id
else
    echo -e "${amarelo}Operação cancelada.${reset}"
    echo -e "${amarelo}Deseja sair? (s/n)${reset}"
    read -p "> " sair
    if [[ "$sair" =~ ^[Ss]$ ]]; then
        echo -e "${amarelo}Saindo...${reset}"
        exit 0
    fi
fi 
