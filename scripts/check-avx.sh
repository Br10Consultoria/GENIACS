#!/usr/bin/env bash
set -e

if lscpu | grep -q "avx"; then
  echo "✅ CPU com AVX detectado"
  exit 0
else
  echo "⚠️ CPU sem AVX detectado"
  exit 1
fi
