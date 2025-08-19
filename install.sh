#!/usr/bin/env bash
set -e

echo "============================================"
echo " 🚀 Instalador Automático GenieACS + Docker "
echo "============================================"
echo

# Verificar se está rodando como root
if [[ "$EUID" -ne 0 ]]; then
   echo "❌ Este script deve ser executado como root!"
   echo "Use: sudo bash install.sh"
   exit 1
fi

# Atualizar sistema
echo "📦 Atualizando sistema..."
apt-get update -y && apt-get upgrade -y

# Remover versões antigas do Docker (se existirem)
echo "🧹 Removendo possíveis versões antigas do Docker..."
apt-get remove -y docker docker-engine docker.io containerd runc || true

# Instalar pacotes necessários
echo "📥 Instalando pacotes base..."
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release git

# Adicionar chave oficial do Docker
echo "🔑 Adicionando chave e repositório do Docker..."
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Atualizar repositórios
apt-get update -y

# Instalar Docker + Compose plugin
echo "🐳 Instalando Docker + Compose..."
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Habilitar e iniciar serviço Docker
systemctl enable docker
systemctl start docker

# Verificar instalação
echo "✅ Docker instalado: $(docker --version)"
echo "✅ Compose instalado: $(docker compose version)"

# Clonar repositório GenieACS Docker
INSTALL_DIR="/opt/genieacs-docker"
echo "📂 Clonando projeto em $INSTALL_DIR ..."
rm -rf "$INSTALL_DIR"
git clone https://github.com/seu-repo/genieacs-docker.git $INSTALL_DIR

cd $INSTALL_DIR

# Dar permissão de execução ao manage.sh
chmod +x scripts/manage.sh

# Subir ambiente
echo "🚀 Subindo ambiente GenieACS..."
./scripts/manage.sh up

echo
echo "============================================"
echo "✅ Instalação concluída!"
echo "GUI disponível em: http://$(hostname -I | awk '{print $1}'):3000"
echo "Usuário: admin | Senha: admin"
echo "============================================"
