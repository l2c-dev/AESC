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

# Caminhos via env.sh (com fallback)
AESC_ROOT="${AESC_ROOT:?AESC_ROOT não definido; verifique etc/env.sh}"

CODES_BASE="${AESC_CODES_DIR:-$AESC_ROOT/codigos}"
SIMS_BASE="${AESC_SIMS_DIR:-$AESC_ROOT/simulacoes}"

CODIGOS_DIR="$CODES_BASE/xfoil"
SIMULACOES_DIR="$SIMS_BASE/xfoil/single_runs"

ALLRUN="$CODIGOS_DIR/Allrun.sh"

clear
echo ""
echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║      🧪 AESC v1.0 | Ambiente de Execução de Simulações Científicas           ║"
echo "║              💻 Laboratório Pessoal de Computação Científica                 ║"
echo "║                Desenvolvido por Prof. Rafael Gabler Gontijo                  ║"
echo "╠══════════════════════════════════════════════════════════════════════════════╣"
echo "║                Ambiente de execução – XFOIL 🛩️ | Caso único                   ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""

if [[ ! -d "$CODIGOS_DIR" ]]; then
  echo "❌ Diretório do código XFOIL não encontrado:"
  echo "   $CODIGOS_DIR"
  read -p "Pressione [Enter] para retornar..."
  bash "$SCRIPT_DIR/menu_xfoil.sh"
  exit 1
fi

if [[ ! -x "$ALLRUN" ]]; then
  echo "❌ Script Allrun.sh não encontrado ou sem permissão:"
  echo "   $ALLRUN"
  read -p "Pressione [Enter] para retornar..."
  bash "$SCRIPT_DIR/menu_xfoil.sh"
  exit 1
fi

mkdir -p "$SIMULACOES_DIR"

read -p "✍️  Digite o perfil NACA (ex: 2412): " AIRFOIL
read -p "🌪️  Digite o número de Reynolds (ex: 1e6): " RE
read -p "🛫 Digite o número de Mach (ex: 0.10): " MACH
read -p "🔁 Digite o número máximo de iterações [padrão: 200]: " ITER
ITER=${ITER:-200}

TIMESTAMP=$(date +%Y%m%d_%H%M%S)

NOME_CASO="NACA${AIRFOIL}_Re${RE}_Mach${MACH}_${TIMESTAMP}"
NOME_CASO_SAFE=$(echo "$NOME_CASO" | tr '+' 'p' | tr '-' 'm' | tr '.' 'p' | tr ',' 'p')

DESTINO_LOCAL="$SIMULACOES_DIR/$NOME_CASO_SAFE"

echo ""
echo "📁 Resultados serão salvos em:"
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

echo "🚀 Executando XFOIL localmente..."
echo ""

env AIRFOIL="$AIRFOIL" RE="$RE" MACH="$MACH" ITER="$ITER" OUTDIR="$DESTINO_LOCAL" \
  "$ALLRUN"

if [[ ! -d "$DESTINO_LOCAL" ]]; then
  echo ""
  echo "❌ O caso não apareceu na pasta final esperada."
  echo "   Verifique a execução do XFOIL."
  read -p "Pressione [Enter] para retornar..."
  bash "$SCRIPT_DIR/menu_xfoil.sh"
  exit 1
fi

echo ""
echo "✅ Caso finalizado com sucesso!"
echo "📁 Resultados salvos em:"
echo "   $DESTINO_LOCAL"
echo ""

read -p "🔁 Deseja rodar outro caso? (s/n): " RESPOSTA
if [[ "$RESPOSTA" =~ ^[Ss]$ ]]; then
  bash "$SCRIPT_DIR/executar_caso.sh"
else
  bash "$SCRIPT_DIR/menu_xfoil.sh"
fi
