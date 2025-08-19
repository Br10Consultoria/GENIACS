#!/usr/bin/env bash
set -e

COMPOSE_FILE=""

detect_avx() {
  if lscpu | grep -q "avx"; then
    echo "✅ CPU com AVX detectada → MongoDB 6.x"
    COMPOSE_FILE="docker-compose.avx.yml"
  else
    echo "⚠️ CPU sem AVX detectada → MongoDB 4.4"
    COMPOSE_FILE="docker-compose.noavx.yml"
  fi
}

print_help() {
  echo "Uso: $0 [up|down|logs|reset]"
  exit 0
}

case "$1" in
  up)
    detect_avx
    echo "🚀 Subindo containers (build forçado, sem cache)..."
    docker compose -f "$COMPOSE_FILE" build --no-cache
    docker compose -f "$COMPOSE_FILE" up -d
    ;;
  down)
    detect_avx
    docker compose -f "$COMPOSE_FILE" down
    ;;
  logs)
    detect_avx
    docker compose -f "$COMPOSE_FILE" logs -f
    ;;
  reset)
    echo "⚠️ Limpando TUDO do Docker (containers, imagens, volumes, cache)"
    read -p "Tem certeza? (y/N): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
      docker compose -f docker-compose.avx.yml down -v --remove-orphans || true
      docker compose -f docker-compose.noavx.yml down -v --remove-orphans || true
      docker system prune -af --volumes
      echo "✅ Docker limpo. Você pode rodar ./scripts/manage.sh up de novo."
    else
      echo "Cancelado."
    fi
    ;;
  *)
    print_help
    ;;
esac