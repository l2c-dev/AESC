#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$ROOT_DIR/bin"

if [[ ! -x "$BIN_DIR/xfoil" ]]; then
  echo "ERRO: bin/xfoil não existe. Rode ./install.sh antes."
  exit 1
fi

AIRFOIL="${AIRFOIL:-2412}"
RE="${RE:-1e6}"
MACH="${MACH:-0.10}"
ITER="${ITER:-200}"
A1="${A1:--4}"
A2="${A2:-14}"
DA="${DA:-0.5}"

OUTDIR="${OUTDIR:-$ROOT_DIR/temp/single_run}"
mkdir -p "$OUTDIR/cp"

CMD_FILE="$OUTDIR/xfoil_commands.in"
LOG_FILE="$OUTDIR/xfoil_run.log"

rm -f "$OUTDIR/polar.dat" "$CMD_FILE" "$LOG_FILE"
rm -f "$OUTDIR"/cp/*.dat 2>/dev/null || true

echo "==> Gerando arquivo de comandos do XFOIL em: $CMD_FILE"

cat > "$CMD_FILE" << EOF
Y
NACA $AIRFOIL
PANE
OPER
VISC
$RE
MACH $MACH
ITER $ITER
PACC
polar.dat

EOF

while IFS= read -r a; do
  a_clean="$(echo "$a" | tr -d '\r')"

  if [[ "$a_clean" == -* ]]; then
    tag="m${a_clean#-}"
  else
    tag="p${a_clean}"
  fi
  tag="$(echo "$tag" | tr '.' 'p' | tr ',' 'p')"

  cpfile="cp/cp_alpha_${tag}.dat"

  cat >> "$CMD_FILE" << EOF
ALFA $a_clean
CPWR $cpfile
EOF
done < <(seq "$A1" "$DA" "$A2")

cat >> "$CMD_FILE" << EOF
PACC

QUIT
EOF

echo "==> Rodando XFOIL..."
cd "$OUTDIR"
xvfb-run -a "$BIN_DIR/xfoil" < "$CMD_FILE" | tee "$LOG_FILE"

echo "==> OK."
echo "    Saídas em: $OUTDIR"
echo "      - polar.dat"
echo "      - cp/"
echo "      - xfoil_run.log"
