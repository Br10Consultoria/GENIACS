#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPOSE_FILE=""

cd "$ROOT_DIR"

require_docker() {
  if ! command -v docker >/dev/null 2>&1; then
    echo "Docker não encontrado. Instale o Docker antes de continuar."
    exit 1
  fi
  if ! docker compose version >/dev/null 2>&1; then
    echo "Docker Compose plugin não encontrado. Instale docker-compose-plugin antes de continuar."
    exit 1
  fi
}

detect_avx() {
  if lscpu 2>/dev/null | grep -qi '\bavx\b'; then
    COMPOSE_FILE="docker-compose.avx.yml"
    echo "CPU com AVX detectada: usando MongoDB 6.0."
  else
    COMPOSE_FILE="docker-compose.noavx.yml"
    echo "CPU sem AVX detectada: usando MongoDB 4.4."
  fi
}

ensure_env() {
  if [[ ! -f .env ]]; then
    if [[ ! -f .env.example ]]; then
      echo "Arquivo .env.example não encontrado."
      exit 1
    fi
    cp .env.example .env
    local secret
    if command -v openssl >/dev/null 2>&1; then
      secret="$(openssl rand -hex 32)"
    else
      secret="$(date +%s%N | sha256sum | awk '{print $1}')"
    fi
    sed -i "s/^GENIEACS_UI_JWT_SECRET=.*/GENIEACS_UI_JWT_SECRET=${secret}/" .env
    echo "Arquivo .env criado automaticamente com GENIEACS_UI_JWT_SECRET forte."
  fi

  if grep -q '^GENIEACS_UI_JWT_SECRET=troque-este-valor' .env; then
    echo "Troque GENIEACS_UI_JWT_SECRET no arquivo .env antes de subir a stack."
    exit 1
  fi
}

compose() {
  docker compose -f "$COMPOSE_FILE" "$@"
}

print_help() {
  cat <<'EOF'
Uso: ./scripts/manage.sh <comando>

Comandos:
  up        Cria .env se necessário, constrói a imagem e sobe a stack
  build     Apenas constrói/reconstrói a imagem local
  down      Para os containers sem remover dados
  restart   Reinicia os serviços
  logs      Exibe logs em tempo real
  ps        Lista containers e healthchecks
  reset     Remove apenas containers, rede e volumes deste projeto
  config    Valida e imprime a configuração final do Docker Compose
EOF
}

require_docker
detect_avx

case "${1:-help}" in
  up)
    ensure_env
    compose build genieacs-cwmp
    compose up -d
    compose ps
    ;;
  build)
    ensure_env
    compose build genieacs-cwmp
    ;;
  down)
    compose down
    ;;
  restart)
    ensure_env
    compose restart
    compose ps
    ;;
  logs)
    compose logs -f --tail=200
    ;;
  ps|status)
    compose ps
    ;;
  reset)
    echo "Isto removerá apenas containers, rede e volumes deste projeto."
    read -r -p "Tem certeza? Digite SIM para continuar: " confirm
    if [[ "$confirm" == "SIM" ]]; then
      docker compose -f docker-compose.avx.yml down -v --remove-orphans || true
      docker compose -f docker-compose.noavx.yml down -v --remove-orphans || true
      echo "Reset concluído."
    else
      echo "Cancelado."
    fi
    ;;
  config)
    ensure_env
    compose config
    ;;
  help|-h|--help)
    print_help
    ;;
  *)
    print_help
    exit 1
    ;;
esac
