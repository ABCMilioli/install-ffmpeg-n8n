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
    
    # Verifica se o FFmpeg já está instalado
    if docker exec $container_id which ffmpeg >/dev/null 2>&1; then
        echo -e "${verde}FFmpeg já está instalado neste container!${reset}"
        echo -e "${amarelo}Versão do FFmpeg instalada:${reset}"
        docker exec $container_id ffmpeg -version
        
        # Pergunta se deseja atualizar
        echo -e "${amarelo}Deseja verificar se há uma versão mais recente disponível? (s/n)${reset}"
        if [ -t 0 ]; then
            read -p "> " atualizar
        else
            if [ -e /dev/tty ]; then
                read -p "> " atualizar < /dev/tty
            else
                atualizar="n"
            fi
        fi
        
        if [[ "$atualizar" =~ ^[Ss]$ ]]; then
            echo -e "${amarelo}Atualizando FFmpeg...${reset}"
            docker exec --privileged -w / $container_id apk add --no-cache --update ffmpeg
            if [ $? -eq 0 ]; then
                echo -e "${verde}FFmpeg atualizado com sucesso!${reset}"
                echo -e "${amarelo}Nova versão do FFmpeg:${reset}"
                docker exec $container_id ffmpeg -version
            else
                echo -e "${vermelho}Erro durante a atualização. Verifique os logs acima para mais detalhes.${reset}"
            fi
        fi
        return 0
    fi
    
    # Instala as dependências
    echo -e "${amarelo}Instalando dependências...${reset}"
    docker exec --privileged -w / $container_id apk add --no-cache --update python3 py3-pip gcc python3-dev musl-dev curl ffmpeg
    
    if [ $? -eq 0 ]; then
        echo -e "${verde}Instalação concluída com sucesso!${reset}"
        echo -e "${amarelo}Versão do FFmpeg instalada:${reset}"
        docker exec $container_id ffmpeg -version
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
    exit 1
fi

# Conta o número de containers n8n
num_containers=$(docker ps --format "{{.Names}}" | grep n8n | wc -l)

# Se houver apenas um container, seleciona automaticamente
if [ "$num_containers" -eq 1 ]; then
    container_name=$(docker ps --format "{{.Names}}" | grep n8n | head -n 1)
    container_id=$(docker ps -q -f name=$container_name)
    echo -e "${amarelo}Container selecionado automaticamente: $container_name${reset}"
    instalar_ffmpeg $container_id
    exit 0
fi

# Se houver múltiplos containers, permite a seleção
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
    exit 1
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
fi 