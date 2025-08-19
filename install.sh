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

# Atualizações e deps
apt-get update -y && apt-get upgrade -y
apt-get install -y curl apt-transport-https ca-certificates unzip gnupg lsb-release git

# Instalar Docker
echo "🐳 Instalando Docker + Compose..."
apt-get remove -y docker docker-engine docker.io containerd runc || true
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" \
  | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl enable docker
systemctl start docker

echo "✅ Docker: $(docker --version)"
echo "✅ Compose: $(docker compose version)"

# Já estamos no diretório local com os arquivos
chmod +x scripts/manage.sh

# Sobe stack automaticamente
./scripts/manage.sh up

IP=$(hostname -I | awk '{print $1}')
echo
echo "============================================"
echo "✅ Instalação concluída!"
echo "GUI disponível em: http://$IP:3000"
echo "Usuário: admin | Senha: admin"
echo "============================================"
