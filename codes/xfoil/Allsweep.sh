#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ALLRUN="$ROOT_DIR/Allrun.sh"
TEMP_DIR="${TEMP_DIR:-$ROOT_DIR/temp}"

mkdir -p "$TEMP_DIR"

if [[ ! -x "$ALLRUN" ]]; then
  echo "ERRO: Allrun.sh não encontrado ou sem permissão de execução."
  exit 1
fi

echo "=============================================="
echo " Varredura automatizada de polares com XFOIL"
echo "=============================================="
echo ""

# ----------------------------
# Entrada: ambiente ou prompt
# ----------------------------
if [[ -z "${AIRFOIL:-}" ]]; then
  read -rp "Informe o perfil NACA (ex: 2412): " AIRFOIL
fi
AIRFOIL="${AIRFOIL:-2412}"

if [[ -z "${MODE:-}" ]]; then
  echo ""
  echo "O que será varrido?"
  echo "1 - Reynolds"
  echo "2 - Mach"
  read -rp "Escolha [1/2]: " MODE
fi

if [[ "$MODE" != "1" && "$MODE" != "2" ]]; then
  echo "ERRO: escolha inválida."
  exit 1
fi

if [[ -z "${VSTART:-}" ]]; then
  read -rp "Valor inicial da varredura: " VSTART
fi

if [[ -z "${VEND:-}" ]]; then
  read -rp "Valor final da varredura: " VEND
fi

if [[ -z "${VSTEP:-}" ]]; then
  read -rp "Passo da varredura: " VSTEP
fi

if [[ "$MODE" == "1" ]]; then
  if [[ -z "${MACH_FIX:-}" ]]; then
    read -rp "Informe o Mach fixo (ex: 0.10): " MACH_FIX
  fi
  MACH_FIX="${MACH_FIX:-0.10}"
  SWEEP_NAME="Re"
  FIXED_DESC="Mach${MACH_FIX}"
else
  if [[ -z "${RE_FIX:-}" ]]; then
    read -rp "Informe o Reynolds fixo (ex: 1e6): " RE_FIX
  fi
  RE_FIX="${RE_FIX:-1e6}"
  SWEEP_NAME="Mach"
  FIXED_DESC="Re${RE_FIX}"
fi

TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
CAMPAIGN_NAME="${CAMPAIGN_NAME:-NACA${AIRFOIL}_${SWEEP_NAME}_sweep_${FIXED_DESC}_${TIMESTAMP}}"
CAMPAIGN_DIR="$TEMP_DIR/$CAMPAIGN_NAME"

mkdir -p "$CAMPAIGN_DIR"

LOGFILE="$CAMPAIGN_DIR/run.log"

# stdout + stderr para terminal e arquivo
exec > >(tee -a "$LOGFILE") 2>&1

echo ""
echo "=============================================="
echo "Iniciando campanha de varredura"
echo "Perfil: NACA $AIRFOIL"
echo "Tipo de sweep: $SWEEP_NAME"
echo "Pasta da campanha:"
echo "$CAMPAIGN_DIR"
echo "=============================================="
echo ""

# ----------------------------
# Geração dos valores da sweep
# sem Python
# ----------------------------
VALUES=$(awk -v start="$VSTART" -v end="$VEND" -v step="$VSTEP" '
BEGIN {
    if (step == 0) {
        print "ERRO: passo não pode ser zero." > "/dev/stderr"
        exit 1
    }

    tol = ((step < 0 ? -step : step) * 1e-9) + 1e-12
    v = start

    if (step > 0) {
        while (v <= end + tol) {
            printf("%.10g\n", v)
            v += step
        }
    } else {
        while (v >= end - tol) {
            printf("%.10g\n", v)
            v += step
        }
    }
}
')

CASE_ID=0

while IFS= read -r VAL; do
  [[ -z "$VAL" ]] && continue

  CASE_ID=$((CASE_ID + 1))

  if [[ "$MODE" == "1" ]]; then
    RE_VAL="$VAL"
    MACH_VAL="$MACH_FIX"
  else
    RE_VAL="$RE_FIX"
    MACH_VAL="$VAL"
  fi

  CASE_TAG="NACA${AIRFOIL}_Re${RE_VAL}_Mach${MACH_VAL}"
  CASE_TAG_SAFE="$(echo "$CASE_TAG" | tr '+' 'p' | tr '-' 'm' | tr '.' 'p' | tr ',' 'p')"
  CASE_DIR="$CAMPAIGN_DIR/$CASE_TAG_SAFE"

  mkdir -p "$CASE_DIR"

  echo ""
  echo "--------------------------------------------------"
  echo "CASO $CASE_ID"
  echo "Perfil = NACA $AIRFOIL"
  echo "Re     = $RE_VAL"
  echo "Mach   = $MACH_VAL"
  echo "Diretório:"
  echo "$CASE_DIR"
  echo "--------------------------------------------------"

  CASE_LOG="$CASE_DIR/case.log"

  AIRFOIL="$AIRFOIL" \
  RE="$RE_VAL" \
  MACH="$MACH_VAL" \
  OUTDIR="$CASE_DIR" \
  "$ALLRUN" | tee "$CASE_LOG"

done <<< "$VALUES"

echo ""
echo "=============================================="
echo "Varredura concluída."
echo "Resultados disponíveis em:"
echo "$CAMPAIGN_DIR"
echo "Log completo em:"
echo "$LOGFILE"
echo "=============================================="
