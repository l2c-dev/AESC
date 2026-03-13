#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$ROOT_DIR/bin"

echo "ROOT_DIR = $ROOT_DIR"

echo "==> Compilando XFOIL..."
cd "$BIN_DIR"
make clean
make xfoil


