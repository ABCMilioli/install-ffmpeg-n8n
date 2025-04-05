# Instalador Automático FFmpeg para n8n

Este script automatiza a instalação do FFmpeg e suas dependências diretamente no container n8n.

## Pré-requisitos

- Docker instalado e em execução
- Stack n8n em execução

## Como usar

1. Primeiro, certifique-se de que o stack n8n está em execução:
```bash
docker stack deploy -c docker-compose.yml n8n
```

2. Dê permissão de execução ao script:
```bash
chmod +x install.sh
```

3. Execute o script:
```bash
./install.sh
```

## O que o script faz

1. Procura automaticamente pelo container n8n
2. Instala as seguintes dependências:
   - python3
   - py3-pip
   - gcc
   - python3-dev
   - musl-dev
   - curl
   - ffmpeg

## Verificação

Após a instalação, você pode verificar se o FFmpeg foi instalado corretamente executando:
```bash
docker exec $(docker ps -q -f name=n8n_regular) ffmpeg -version
```

## Solução de Problemas

Se você encontrar algum erro:
1. Verifique se o stack n8n está em execução
2. Verifique se o container n8n está ativo
3. Verifique os logs do container para mais detalhes 