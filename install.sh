#!/usr/bin/env bash
set -e

echo "============================================"
echo " 🚀 Instalador Automático GenieACS + Docker "
echo "============================================"
echo

if [[ "$EUID" -ne 0 ]]; then
   echo "❌ Execute como root!"
   exit 1
fi

echo "📦 Atualizando sistema..."
apt-get update -y && apt-get upgrade -y

echo "🧹 Removendo docker antigo (se existir)..."
apt-get remove -y docker docker-engine docker.io containerd runc || true

echo "📥 Instalando dependências..."
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release unzip

echo "🔑 Configurando repositório Docker..."
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl enable docker
systemctl start docker

echo "✅ Docker versão: $(docker --version)"
echo "✅ Docker Compose versão: $(docker compose version)"

chmod +x scripts/manage.sh

echo "🚀 Subindo a stack do GenieACS..."
./scripts/manage.sh up

IP=$(hostname -I | awk '{print $1}')
echo
echo "============================================"
echo "✅ Instalação concluída!"
echo "GUI disponível em: http://$IP:3000"
echo "Usuário: admin | Senha: admin"
echo "============================================"
