#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$ROOT_DIR/bin"
TOOLS_DIR="$ROOT_DIR/tools"
VENV_DIR="$ROOT_DIR/.venv"
RUNS_DIR="$ROOT_DIR/runs"
TEMP_DIR="$ROOT_DIR/temp"

DEEP=1
PURGE_RUNS=0

usage() {
  cat <<EOF
Uso:
  ./Allclean.sh               # limpa artefatos gerados (build + run + pós + sweeps)
  ./Allclean.sh --deep        # também remove .venv
  ./Allclean.sh --purge-runs  # também apaga arquivos em runs/ (CUIDADO)
  ./Allclean.sh --deep --purge-runs

Preserva:
  - src/, osrc/, tools/*.py, tools/*.f90
  - bin/Makefile e bin/xfoil.def
  - plotlib/ (não mexe)
  - runs/ (a menos que --purge-runs)
EOF
}

if [[ $# -gt 0 ]]; then
  for arg in "$@"; do
    case "$arg" in
      --deep) DEEP=1 ;;
      --purge-runs) PURGE_RUNS=1 ;;
      -h|--help) usage; exit 0 ;;
      *) echo "Argumento desconhecido: $arg"; usage; exit 1 ;;
    esac
  done
fi

echo "==> Limpando artefatos gerados..."

# -------------------------
# 1) bin/: build + run + pos
# -------------------------
if [[ -d "$BIN_DIR" ]]; then
  echo " -> Limpando bin/ (objetos, executáveis e saídas)..."

  if [[ -f "$BIN_DIR/Makefile" ]]; then
    ( cd "$BIN_DIR" && make clean >/dev/null 2>&1 || true )
  fi

  rm -f "$BIN_DIR/xfoil" "$BIN_DIR/pplot" "$BIN_DIR/pxplot" 2>/dev/null || true

  rm -f "$BIN_DIR/polar.dat" \
        "$BIN_DIR/dump.dat" \
        "$BIN_DIR/dump_points.csv" \
        "$BIN_DIR/dump_integrated.csv" \
        "$BIN_DIR/xfoil_commands.in" \
        "$BIN_DIR/xfoil_run.log" \
        2>/dev/null || true

  rm -rf "$BIN_DIR/figs" "$BIN_DIR/cp" 2>/dev/null || true

  find "$BIN_DIR" -maxdepth 1 -type f \( \
      -name "*.o" -o -name "*.mod" -o -name "*.obj" -o -name "*.exe" \
    \) -delete 2>/dev/null || true
fi

# -------------------------
# 2) temp/: campanhas e casos de sweep
# -------------------------
if [[ -d "$TEMP_DIR" ]]; then
  echo " -> Limpando temp/ (campanhas, casos, logs, figuras e Cp)..."
  rm -rf "$TEMP_DIR"/*
fi

# -------------------------
# 3) tools/: binários auxiliares gerados
# -------------------------
if [[ -d "$TOOLS_DIR" ]]; then
  echo " -> Limpando tools/ (binários auxiliares)..."
  rm -f "$TOOLS_DIR/dump2csv" 2>/dev/null || true
fi

# -------------------------
# 4) venv: opcional
# -------------------------
if [[ "$DEEP" -eq 1 ]]; then
  echo " -> (deep) Removendo .venv/ ..."
  rm -rf "$VENV_DIR" 2>/dev/null || true
fi

# -------------------------
# 5) runs/: opcional
# -------------------------
if [[ "$PURGE_RUNS" -eq 1 ]]; then
  if [[ -d "$RUNS_DIR" ]]; then
    echo " -> (purge-runs) Esvaziando runs/ ..."
    rm -f "$RUNS_DIR"/* 2>/dev/null || true
  fi
fi

echo "==> OK: limpeza concluída."
