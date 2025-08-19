#!/usr/bin/env bash
set -e
cd "$(dirname "$0")/.."
docker compose -f docker-compose.avx.yml logs -f || \
docker compose -f docker-compose.noavx.yml logs -f
