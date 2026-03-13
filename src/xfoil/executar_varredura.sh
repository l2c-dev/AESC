#!/bin/bash

# ─────────────────────────── Carrega env.sh (mínimo e idempotente) ─────────────
_AESC_LOADER_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
AESC_ROOT="$(cd "$_AESC_LOADER_DIR/../.." && pwd)"
for _aesc_env in "$AESC_ROOT/etc/env.sh" "$AESC_ROOT/src/env.sh" "$AESC_ROOT/env.sh"; do
  [ -f "$_aesc_env" ] && . "$_aesc_env" && break
done
unset _aesc_env _AESC_LOADER_DIR
# ────────────────────────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

AESC_ROOT="${AESC_ROOT:?AESC_ROOT não definido; verifique etc/env.sh}"
CODES_BASE="${AESC_CODES_DIR:-$AESC_ROOT/codigos}"
SIMS_BASE="${AESC_SIMS_DIR:-$AESC_ROOT/simulacoes}"

CODIGOS_DIR="$CODES_BASE/xfoil"
SIMULACOES_DIR="$SIMS_BASE/xfoil/sweeps"
ALLSWEEP="$CODIGOS_DIR/Allsweep.sh"

clear
echo ""
echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║      🧪 AESC v1.0 | Ambiente de Execução de Simulações Científicas           ║"
echo "║              💻 Laboratório Pessoal de Computação Científica                 ║"
echo "║                Desenvolvido por Prof. Rafael Gabler Gontijo                  ║"
echo "╠══════════════════════════════════════════════════════════════════════════════╣"
echo "║              Ambiente de execução – XFOIL 🛩️ | Executar varredura             ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""

if [[ ! -d "$CODIGOS_DIR" ]]; then
  echo "❌ Diretório do código XFOIL não encontrado:"
  echo "   $CODIGOS_DIR"
  read -p "Pressione [Enter] para retornar..."
  bash "$SCRIPT_DIR/menu_xfoil.sh"
  exit 1
fi

if [[ ! -x "$ALLSWEEP" ]]; then
  echo "❌ Script Allsweep.sh não encontrado ou sem permissão:"
  echo "   $ALLSWEEP"
  read -p "Pressione [Enter] para retornar..."
  bash "$SCRIPT_DIR/menu_xfoil.sh"
  exit 1
fi

mkdir -p "$SIMULACOES_DIR"

read -p "✍️  Digite o perfil NACA (ex: 2412): " AIRFOIL

echo ""
echo "O que será varrido?"
echo "1 - Reynolds"
echo "2 - Mach"
read -p "Escolha [1/2]: " MODE

if [[ "$MODE" != "1" && "$MODE" != "2" ]]; then
  echo "❌ Opção inválida."
  read -p "Pressione [Enter] para retornar..."
  bash "$SCRIPT_DIR/menu_xfoil.sh"
  exit 1
fi

read -p "📈 Valor inicial da varredura: " VSTART
read -p "📉 Valor final da varredura: " VEND
read -p "🔁 Passo da varredura: " VSTEP

if [[ "$MODE" == "1" ]]; then
  read -p "🛫 Informe o Mach fixo (ex: 0.10): " MACH_FIX
  MACH_FIX="${MACH_FIX:-0.10}"
  SWEEP_NAME="Re"
  FIXED_DESC="Mach${MACH_FIX}"
else
  read -p "🌪️  Informe o Reynolds fixo (ex: 1e6): " RE_FIX
  RE_FIX="${RE_FIX:-1e6}"
  SWEEP_NAME="Mach"
  FIXED_DESC="Re${RE_FIX}"
fi

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
CAMPAIGN_NAME="NACA${AIRFOIL}_${SWEEP_NAME}_sweep_${FIXED_DESC}_${TIMESTAMP}"
CAMPAIGN_NAME_SAFE=$(echo "$CAMPAIGN_NAME" | tr '+' 'p' | tr '-' 'm' | tr '.' 'p' | tr ',' 'p')

DESTINO_LOCAL="$SIMULACOES_DIR/$CAMPAIGN_NAME_SAFE"

echo ""
echo "📁 A campanha será salva em:"
echo "   $DESTINO_LOCAL"
echo ""

cd "$CODIGOS_DIR" || exit 1

if [[ ! -x "$CODIGOS_DIR/bin/xfoil" ]]; then
  echo "🛠️  Executável do XFOIL não encontrado. Rodando ./install.sh ..."
  ./install.sh || {
    echo "❌ Falha ao compilar/instalar o XFOIL."
    read -p "Pressione [Enter] para retornar..."
    bash "$SCRIPT_DIR/menu_xfoil.sh"
    exit 1
  }
fi

echo "🚀 Executando campanha localmente..."
echo ""

env AIRFOIL="$AIRFOIL" \
    MODE="$MODE" \
    VSTART="$VSTART" \
    VEND="$VEND" \
    VSTEP="$VSTEP" \
    MACH_FIX="${MACH_FIX:-}" \
    RE_FIX="${RE_FIX:-}" \
    CAMPAIGN_NAME="$CAMPAIGN_NAME_SAFE" \
    TEMP_DIR="$SIMULACOES_DIR" \
    "$ALLSWEEP"

if [[ ! -d "$DESTINO_LOCAL" ]]; then
  echo ""
  echo "❌ A campanha não apareceu na pasta final esperada."
  echo "   Verifique a execução do XFOIL."
  read -p "Pressione [Enter] para retornar..."
  bash "$SCRIPT_DIR/menu_xfoil.sh"
  exit 1
fi

echo ""
echo "✅ Campanha finalizada com sucesso!"
echo "📁 Resultados salvos em:"
echo "   $DESTINO_LOCAL"
echo ""

read -p "🔁 Deseja rodar outra campanha? (s/n): " RESPOSTA
if [[ "$RESPOSTA" =~ ^[Ss]$ ]]; then
  bash "$SCRIPT_DIR/executar_varredura.sh"
else
  bash "$SCRIPT_DIR/menu_xfoil.sh"
fi
