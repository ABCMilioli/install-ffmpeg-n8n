# Instalador FFmpeg para n8n

Este script automatiza a instalação do FFmpeg e suas dependências em containers n8n.

## 🚀 Características

- Interface interativa com menu colorido
- Seleção automática de containers n8n
- Instalação segura com confirmação
- Verificação de permissões root
- Feedback visual do processo de instalação
- Tratamento de erros robusto

## 📋 Pré-requisitos

- Docker instalado e em execução
- Stack n8n em execução
- Acesso root (sudo)

## 🛠️ Instalação

1. Clone o repositório:
```bash
git clone https://github.com/ABCMilioli/install-ffmpeg-n8n.git
cd install-ffmpeg-n8n
```

2. Dê permissão de execução ao script:
```bash
chmod +x install.sh
```

3. Execute o script como root:
```bash
sudo bash install.sh
```

## 📝 Como usar

1. O script mostrará um banner e listará todos os containers n8n disponíveis
2. Digite o número do container onde deseja instalar o FFmpeg
3. Confirme a instalação digitando 's' ou 'n'
4. Aguarde a conclusão da instalação

## 🔍 Verificação

Após a instalação, você pode verificar se o FFmpeg foi instalado corretamente executando:
```bash
docker exec [container_id] ffmpeg -version
```

## ⚠️ Solução de Problemas

Se você encontrar algum erro:
1. Verifique se o stack n8n está em execução
2. Verifique se o container n8n está ativo
3. Verifique os logs do container para mais detalhes
4. Certifique-se de que está executando o script como root

## 🤝 Contribuindo

Contribuições são bem-vindas! Por favor, sinta-se à vontade para:
1. Fazer um fork do projeto
2. Criar uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abrir um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## 👥 Autores

- **Assistant** - *Trabalho inicial* - [Assistant](https://github.com/assistant)
- **Robson Milioli** - *Adaptações e melhorias* - [ABCMilioli](https://github.com/ABCMilioli)

## 🙏 Agradecimentos

- N8N Team
- Docker Community
- FFmpeg Team 