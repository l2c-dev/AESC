#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ALLPOS="$ROOT_DIR/Allpos.sh"
VENV_DIR="$ROOT_DIR/.venv"
TOOLS_DIR="$ROOT_DIR/tools"

PYTHON="$VENV_DIR/bin/python"

CAMPAIGN_DIR="${1:-}"

if [[ -z "$CAMPAIGN_DIR" ]]; then
  echo ""
  echo "Uso:"
  echo "  ./Allsweep_pos.sh <pasta_da_campanha>"
  echo ""
  exit 1
fi

if [[ ! -d "$CAMPAIGN_DIR" ]]; then
  echo "❌ campanha não encontrada:"
  echo "   $CAMPAIGN_DIR"
  exit 2
fi

if [[ ! -x "$ALLPOS" ]]; then
  echo "❌ Allpos.sh não encontrado ou sem permissão."
  exit 3
fi

if [[ ! -x "$PYTHON" ]]; then
  echo ""
  echo "❌ Ambiente Python não encontrado."
  echo "   Esperado em:"
  echo "   $VENV_DIR"
  echo ""
  exit 4
fi

RUNLOG="$CAMPAIGN_DIR/post_run.log"
exec > >(tee -a "$RUNLOG") 2>&1

echo ""
echo "=============================================="
echo " Pós-processamento da campanha"
echo " Campanha:"
echo " $CAMPAIGN_DIR"
echo "=============================================="
echo ""

CASE_COUNT=0

for CASE_DIR in "$CAMPAIGN_DIR"/*; do

  [[ ! -d "$CASE_DIR" ]] && continue

  if [[ -f "$CASE_DIR/polar.dat" && -d "$CASE_DIR/cp" ]]; then

    CASE_COUNT=$((CASE_COUNT + 1))

    echo "--------------------------------------------------"
    echo "Caso $CASE_COUNT"
    echo "$CASE_DIR"
    echo "--------------------------------------------------"

    "$ALLPOS" "$CASE_DIR"

    echo ""

  fi

done

echo ""
echo "==> Consolidando campanha..."

"$PYTHON" "$TOOLS_DIR/consolidate_sweep.py" \
  --campaign "$CAMPAIGN_DIR"

echo ""
echo "=============================================="
echo " Pós-processamento da campanha concluído"
echo " Casos processados: $CASE_COUNT"
echo " Log: $RUNLOG"
echo "=============================================="
