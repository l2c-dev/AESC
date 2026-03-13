#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

VENV_DIR="$ROOT_DIR/.venv"
TOOLS_DIR="$ROOT_DIR/tools"

CASE_DIR="${1:-$ROOT_DIR/temp/single_run}"

POLAR="$CASE_DIR/polar.dat"
CP_DIR="$CASE_DIR/cp"
OUTDIR="$CASE_DIR/figs"

PYTHON="$VENV_DIR/bin/python"

if [[ ! -x "$PYTHON" ]]; then
  echo ""
  echo "❌ Ambiente Python não encontrado."
  echo "   Esperado em:"
  echo "   $VENV_DIR"
  echo ""
  echo "Crie o ambiente com:"
  echo "   python3 -m venv .venv"
  echo "   source .venv/bin/activate"
  echo "   pip install numpy matplotlib pandas"
  echo ""
  exit 1
fi

if [[ ! -f "$POLAR" ]]; then
  echo "❌ polar.dat não encontrado em:"
  echo "   $CASE_DIR"
  exit 2
fi

if [[ ! -d "$CP_DIR" ]]; then
  echo "❌ pasta cp não encontrada em:"
  echo "   $CASE_DIR"
  exit 3
fi

mkdir -p "$OUTDIR"

echo ""
echo "=============================================="
echo " Pós-processamento de caso XFOIL"
echo " Caso:"
echo " $CASE_DIR"
echo "=============================================="
echo ""

"$PYTHON" "$TOOLS_DIR/plot_results.py" \
  --polar "$POLAR" \
  --cp_dir "$CP_DIR" \
  --outdir "$OUTDIR"

echo ""
echo "✅ Pós-processamento concluído."
echo "📁 Figuras salvas em:"
echo "   $OUTDIR"
