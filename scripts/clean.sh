#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/.."
docker compose -f docker-compose.avx.yml down -v || true
docker compose -f docker-compose.noavx.yml down -v || true
