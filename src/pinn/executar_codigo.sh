#!/bin/bash

# ─────────────────────────── Carrega env.sh (mínimo e idempotente) ─────────────
_AESC_LOADER_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
AESC_ROOT="$(cd "$_AESC_LOADER_DIR/../.." && pwd)"
for _aesc_env in "$AESC_ROOT/etc/env.sh" "$AESC_ROOT/src/env.sh" "$AESC_ROOT/env.sh"; do
  [ -f "$_aesc_env" ] && . "$_aesc_env" && break
done
unset _aesc_env _AESC_LOADER_DIR
# ────────────────────────────────────────────────────────────────────────────────

# Diretórios relativos
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# ─────────────────────────── Caminhos via env.sh (com fallbacks) ───────────────
AESC_ROOT="${AESC_ROOT:?AESC_ROOT não definido; verifique etc/env.sh}"
CODES_BASE="${AESC_CODES_DIR:-$AESC_ROOT/codes}"
SIMS_BASE="${AESC_SIMS_DIR:-$AESC_ROOT/simulations}"

COD_DIR="$CODES_BASE/pinn"
SIM_DIR="$SIMS_BASE/pinn"

# Python/venv
PY_CMD="${AESC_PY_CMD:-python3}"
PINN_VENV="${AESC_PINN_VENV:-$HOME/venvs/pinn}"

clear
echo ""
echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║      🧪 AESC v1.0 | Ambiente de Execução de Simulações Científicas           ║"
echo "║              💻 Laboratório Pessoal de Computação Científica                 ║"
echo "║                Desenvolvido por Prof. Rafael Gabler Gontijo                  ║"
echo "╠══════════════════════════════════════════════════════════════════════════════╣"
echo "║                 Ambiente de execução – PINN 🤖 | Executar código             ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""

# Checagens básicas
if [[ ! -d "$COD_DIR" ]]; then
  echo "❌ Diretório de códigos PINN não encontrado: $COD_DIR"
  read -r -p "Pressione ENTER para retornar ao menu PINN..."
  exec bash "$SCRIPT_DIR/menu_pinn.sh"
fi
if [[ ! -d "$SIM_DIR" ]]; then
  echo "❌ Diretório de simulações PINN não encontrado: $SIM_DIR"
  read -r -p "Pressione ENTER para retornar ao menu PINN..."
  exec bash "$SCRIPT_DIR/menu_pinn.sh"
fi

# Ativa o venv do PINN (se existir)
if [[ -f "$PINN_VENV/bin/activate" ]]; then
  # shellcheck disable=SC1091
  source "$PINN_VENV/bin/activate"
else
  echo "⚠️  Ambiente virtual não encontrado em: $PINN_VENV"
  echo "    Prosseguindo com Python do sistema (pode falhar se pacotes não estiverem instalados)."
fi

# Lista scripts .py em COD_DIR
mapfile -t SCRIPTS < <(cd "$COD_DIR" && find . -maxdepth 1 -type f -name "*.py" -printf "%f\n" | sort)
if [[ ${#SCRIPTS[@]} -eq 0 ]]; then
  echo "⚠️ Nenhum script .py encontrado em $COD_DIR"
  read -r -p "Pressione ENTER para retornar ao menu PINN..."
  exec bash "$SCRIPT_DIR/menu_pinn.sh"
fi

echo "📜 Scripts disponíveis em $(basename "$COD_DIR"):"
for s in "${SCRIPTS[@]}"; do echo "  - ${s%.py}"; done
echo ""
read -r -p "Digite o nome do código (sem .py): " nome

if [[ -z "$nome" ]]; then
  echo "❌ Nome vazio."
  read -r -p "Pressione ENTER para retornar ao menu PINN..."
  exec bash "$SCRIPT_DIR/menu_pinn.sh"
fi

ALVO="$COD_DIR/$nome.py"
if [[ ! -f "$ALVO" ]]; then
  echo "❌ Script não encontrado: $ALVO"
  read -r -p "Pressione ENTER para retornar ao menu PINN..."
  exec bash "$SCRIPT_DIR/menu_pinn.sh"
fi

# Cria pasta de saída em simulations/pinn e exporta AESC_OUTDIR
mkdir -p "$SIM_DIR"
RUN_TS="$(date +'%Y%m%d-%H%M%S')"
RUN_DIR="$SIM_DIR/pinn_run_${RUN_TS}"
mkdir -p "$RUN_DIR"

export AESC_OUTDIR="$RUN_DIR"

echo ""
echo "📁 Pasta de saída configurada para esta execução:"
echo "   $RUN_DIR"
echo "   (o script Python gravará parâmetros, log.treino, VTK e figuras nessa pasta)"
echo ""
echo "🚀 Executando: $PY_CMD $(basename "$ALVO")"
echo "   ➜ Após responder às perguntas, a simulação será enviada para o background"
echo "   ➜ O próprio script exibirá o PID do processo e o caminho do log."
echo ""

# Executa no diretório de códigos, deixando o Python cuidar do detach/background
cd "$COD_DIR" || {
  echo "❌ Falha ao acessar $COD_DIR"
  read -r -p "Pressione ENTER para retornar ao menu PINN..."
  exec bash "$SCRIPT_DIR/menu_pinn.sh"
}

"$PY_CMD" "$(basename "$ALVO")"
PY_STATUS=$?

echo ""
if [[ $PY_STATUS -ne 0 ]]; then
  echo "❌ O script Python retornou código de erro ($PY_STATUS)."
  echo "   Verifique as mensagens acima e, se existir, o arquivo:"
  echo "   $RUN_DIR/log.treino"
  read -r -p "Pressione ENTER para retornar ao menu PINN..."
  exec bash "$SCRIPT_DIR/menu_pinn.sh"
fi

echo "✅ Rotina de lançamento concluída."
echo "   Se nenhum erro foi exibido acima, a simulação deve estar rodando em background."
echo "   Pasta da simulação: $RUN_DIR"
echo "   Log principal:       $RUN_DIR/log.treino"
echo ""
read -r -p "Pressione ENTER para retornar ao menu PINN..."
exec bash "$SCRIPT_DIR/menu_pinn.sh"
