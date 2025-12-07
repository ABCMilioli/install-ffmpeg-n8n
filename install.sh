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
        echo -e "${amarelo}O que você deseja fazer?${reset}"
        echo -e "1) Desinstalar FFmpeg"
        echo -e "2) Escolher outro container"
        echo -e "3) Sair"
        if [ -t 0 ]; then
            read -p "> " opcao
        else
            if [ -e /dev/tty ]; then
                read -p "> " opcao < /dev/tty
            else
                opcao="3"
            fi
        fi

        case $opcao in
            1)
                echo -e "${amarelo}Desinstalando FFmpeg...${reset}"
                docker exec --user root --privileged -w / $container_id sh -c "apk del ffmpeg"
                if [ $? -eq 0 ]; then
                    echo -e "${verde}FFmpeg desinstalado com sucesso!${reset}"
                else
                    echo -e "${vermelho}Erro durante a desinstalação. Verifique os logs acima para mais detalhes.${reset}"
                fi
                ;;
            2)
                echo -e "${amarelo}Retornando à seleção de containers...${reset}"
                return 2
                ;;
            3)
                echo -e "${amarelo}Saindo...${reset}"
                exit 0
                ;;
            *)
                echo -e "${vermelho}Opção inválida! Saindo...${reset}"
                exit 1
                ;;
        esac
        return 0
    fi
    
    # Instala as dependências
    echo -e "${amarelo}Instalando dependências...${reset}"
    # Primeiro atualiza o repositório, depois atualiza os pacotes instalados para resolver conflitos
    # e por fim instala a versão mais recente dos novos pacotes
    docker exec --user root --privileged -w / $container_id sh -c "apk update && apk upgrade && apk add --no-cache --latest python3 py3-pip gcc python3-dev musl-dev curl ffmpeg"
    
    if [ $? -eq 0 ]; then
        echo -e "${verde}Instalação concluída com sucesso!${reset}"
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
else
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
fi

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
    while true; do
        instalar_ffmpeg $container_id
        if [ $? -eq 2 ]; then
            # Retorna à seleção de containers
            listar_containers
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

            if [[ "$opcao" =~ ^[Qq]$ ]]; then
                echo -e "${amarelo}Saindo...${reset}"
                exit 0
            fi

            if ! [[ "$opcao" =~ ^[0-9]+$ ]]; then
                echo -e "${vermelho}Opção inválida! Digite um número válido ou 'q' para sair.${reset}"
                exit 1
            fi

            container_name=$(docker ps --format "{{.Names}}" | grep n8n | sed -n "${opcao}p")
            if [ -z "$container_name" ]; then
                echo -e "${vermelho}Container não encontrado!${reset}"
                exit 1
            fi
            container_id=$(docker ps -q -f name=$container_name)
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
                continue
            else
                echo -e "${amarelo}Operação cancelada.${reset}"
                exit 0
            fi
        else
            break
        fi
    done
else
    echo -e "${amarelo}Operação cancelada.${reset}"
fi 
