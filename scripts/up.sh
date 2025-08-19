#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/.."

if ./scripts/check-avx.sh; then
  echo "Subindo stack com MongoDB 6.x (CPU com AVX)"
  docker compose -f docker-compose.avx.yml up -d --build
else
  echo "Subindo stack com MongoDB 4.4 (CPU sem AVX)"
  docker compose -f docker-compose.noavx.yml up -d --build
fi
