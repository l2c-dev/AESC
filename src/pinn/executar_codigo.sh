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

# Snapshot de diretórios ANTES (dentro de COD_DIR)
cd "$COD_DIR" || { echo "❌ Falha ao acessar $COD_DIR"; read -r -p "ENTER..."; exec bash "$SCRIPT_DIR/menu_pinn.sh"; }
mapfile -t DIRS_BEFORE < <(find . -maxdepth 1 -mindepth 1 -type d ! -name ".*" ! -name "__pycache__" -printf "%P\n" | sort)

echo ""
echo "🚀 Executando: $PY_CMD $(basename "$ALVO")"
echo "   (aguarde a finalização do código; logs/prints são do script Python)"
echo ""

# Execução síncrona
"$PY_CMD" "$ALVO"
PY_STATUS=$?

echo ""
if [[ $PY_STATUS -ne 0 ]]; then
  echo "❌ Execução retornou código de erro ($PY_STATUS)."
  echo "   Verifique a saída acima e eventuais logs gerados pelo script."
  read -r -p "Pressione ENTER para retornar ao menu PINN..."
  exec bash "$SCRIPT_DIR/menu_pinn.sh"
fi

# Snapshot de diretórios DEPOIS (dentro de COD_DIR)
mapfile -t DIRS_AFTER < <(find . -maxdepth 1 -mindepth 1 -type d ! -name ".*" ! -name "__pycache__" -printf "%P\n" | sort)

# Calcula novos diretórios criados
declare -A SEEN
for d in "${DIRS_BEFORE[@]}"; do SEEN["$d"]=1; done
NEW_DIRS=()
for d in "${DIRS_AFTER[@]}"; do
  if [[ -z "${SEEN[$d]}" ]]; then NEW_DIRS+=("$d"); fi
done

TARGET_DIR=""
if [[ ${#NEW_DIRS[@]} -gt 0 ]]; then
  # Se múltiplos, pega o mais recente por mtime
  newest=$(printf "%s\n" "${NEW_DIRS[@]}" | while read -r dn; do stat -c "%Y %n" "$dn"; done | sort -n | tail -1 | cut -d' ' -f2-)
  TARGET_DIR="$newest"
else
  # Fallback: pega diretório mais recente em COD_DIR
  newest=$(find . -maxdepth 1 -mindepth 1 -type d ! -name ".*" ! -name "__pycache__" -printf "%T@ %P\n" | sort -n | tail -1 | cut -d' ' -f2-)
  TARGET_DIR="$newest"
fi

if [[ -z "$TARGET_DIR" || ! -d "$TARGET_DIR" ]]; then
  echo "⚠️ Não foi possível identificar a pasta de saída criada pelo script."
  read -r -p "Pressione ENTER para retornar ao menu PINN..."
  exec bash "$SCRIPT_DIR/menu_pinn.sh"
fi

# Move a pasta para simulations/pinn
SRC_ABS="$COD_DIR/$TARGET_DIR"
DEST_ABS="$SIM_DIR/$(basename "$TARGET_DIR")"
if [[ -e "$DEST_ABS" ]]; then
  TS="$(date +'%Y%m%d-%H%M%S')"
  DEST_ABS="${DEST_ABS}_$TS"
fi

echo "📦 Movendo saída:"
echo "   De: $SRC_ABS"
echo "   Para: $DEST_ABS"
mv "$SRC_ABS" "$DEST_ABS"

echo ""
echo "✅ Execução concluída e saída organizada."
echo "📁 Pasta da simulação: $DEST_ABS"
echo ""
read -r -p "Pressione ENTER para retornar ao menu PINN..."
exec bash "$SCRIPT_DIR/menu_pinn.sh"
