#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

echo "============================================"
echo " Instalador GENIACS — GenieACS + Docker"
echo "============================================"

if [[ "${EUID}" -ne 0 ]]; then
  echo "Execute com sudo: sudo ./install.sh"
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive

echo "Configurando timezone America/Bahia..."
if command -v timedatectl >/dev/null 2>&1; then
  timedatectl set-timezone America/Bahia || true
else
  ln -snf /usr/share/zoneinfo/America/Bahia /etc/localtime
  echo America/Bahia > /etc/timezone
fi

echo "Instalando dependências básicas..."
apt-get update -y
apt-get install -y ca-certificates curl gnupg lsb-release openssl

install_docker() {
  . /etc/os-release

  local docker_os=""
  case "${ID}" in
    ubuntu) docker_os="ubuntu" ;;
    debian) docker_os="debian" ;;
    *)
      if echo "${ID_LIKE:-}" | grep -qi "ubuntu"; then
        docker_os="ubuntu"
      elif echo "${ID_LIKE:-}" | grep -qi "debian"; then
        docker_os="debian"
      else
        echo "Distribuição não suportada automaticamente: ${PRETTY_NAME:-desconhecida}."
        echo "Instale Docker Engine manualmente e depois rode: ./scripts/manage.sh up"
        exit 1
      fi
      ;;
  esac

  echo "Docker não encontrado. Instalando Docker Engine oficial para ${docker_os}/${VERSION_CODENAME}..."
  install -m 0755 -d /etc/apt/keyrings
  rm -f /etc/apt/keyrings/docker.gpg
  curl -fsSL "https://download.docker.com/linux/${docker_os}/gpg" | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg

  cat > /etc/apt/sources.list.d/docker.list <<EOF
  deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/${docker_os} ${VERSION_CODENAME} stable
EOF

  apt-get update -y
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

if ! command -v docker >/dev/null 2>&1; then
  install_docker
else
  echo "Docker já está instalado."
fi

if ! docker compose version >/dev/null 2>&1; then
  echo "Docker Compose plugin não encontrado. Instalando pacote docker-compose-plugin..."
  apt-get update -y
  apt-get install -y docker-compose-plugin
fi

systemctl enable docker >/dev/null 2>&1 || true
systemctl start docker >/dev/null 2>&1 || true

chmod +x scripts/manage.sh

echo "Subindo a stack corrigida..."
./scripts/manage.sh up

IP="$(hostname -I | awk '{print $1}')"
cat <<EOF

============================================
Instalação concluída.

Interface web: http://${IP}:3000
Logs:          ./scripts/manage.sh logs
Status:        ./scripts/manage.sh ps
Parar:         ./scripts/manage.sh down

Importante: mantenha o arquivo .env fora do Git e coloque a interface web atrás de HTTPS em produção.
============================================
EOF
