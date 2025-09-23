#!/bin/bash

# Diretórios relativos
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
COD_DIR="$(readlink -f "$ROOT_DIR/../codigos/pinn")"
SIM_DIR="$(readlink -f "$ROOT_DIR/../simulacoes/pinn")"

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
  read -p "Pressione ENTER para retornar ao menu PINN..."; bash "$SCRIPT_DIR/menu_pinn.sh"; exit 1
fi
if [[ ! -d "$SIM_DIR" ]]; then
  echo "❌ Diretório de simulações PINN não encontrado: $SIM_DIR"
  read -p "Pressione ENTER para retornar ao menu PINN..."; bash "$SCRIPT_DIR/menu_pinn.sh"; exit 1
fi

# Ativa o venv do PINN
if [[ -f "$HOME/venvs/pinn/bin/activate" ]]; then
  # shellcheck disable=SC1091
  source "$HOME/venvs/pinn/bin/activate"
else
  echo "⚠️  Ambiente virtual não encontrado em: $HOME/venvs/pinn"
  echo "    Prosseguindo com Python do sistema (pode falhar se pacotes não estiverem instalados)."
fi

# Lista scripts .py em COD_DIR
mapfile -t SCRIPTS < <(cd "$COD_DIR" && find . -maxdepth 1 -type f -name "*.py" -printf "%f\n" | sort)
if [[ ${#SCRIPTS[@]} -eq 0 ]]; then
  echo "⚠️ Nenhum script .py encontrado em $COD_DIR"
  read -p "Pressione ENTER para retornar ao menu PINN..."; bash "$SCRIPT_DIR/menu_pinn.sh"; exit 0
fi

echo "📜 Scripts disponíveis em $(basename "$COD_DIR"):"
for s in "${SCRIPTS[@]}"; do echo "  - ${s%.py}"; done
echo ""
read -p "Digite o nome do código (sem .py): " nome

if [[ -z "$nome" ]]; then
  echo "❌ Nome vazio."
  read -p "Pressione ENTER para retornar ao menu PINN..."; bash "$SCRIPT_DIR/menu_pinn.sh"; exit 1
fi

ALVO="$COD_DIR/$nome.py"
if [[ ! -f "$ALVO" ]]; then
  echo "❌ Script não encontrado: $ALVO"
  read -p "Pressione ENTER para retornar ao menu PINN..."; bash "$SCRIPT_DIR/menu_pinn.sh"; exit 1
fi

# Snapshot de diretórios ANTES (dentro de COD_DIR)
cd "$COD_DIR" || { echo "❌ Falha ao acessar $COD_DIR"; read -p "ENTER..."; bash "$SCRIPT_DIR/menu_pinn.sh"; exit 1; }
mapfile -t DIRS_BEFORE < <(find . -maxdepth 1 -mindepth 1 -type d ! -name ".*" ! -name "__pycache__" -printf "%P\n" | sort)

echo ""
echo "🚀 Executando: python $(basename "$ALVO")"
echo "   (aguarde a finalização do código; logs/prints são do script Python)"
echo ""

# Execução síncrona
python "$ALVO"
PY_STATUS=$?

echo ""
if [[ $PY_STATUS -ne 0 ]]; then
  echo "❌ Execução retornou código de erro ($PY_STATUS)."
  echo "   Verifique a saída acima e eventuais logs gerados pelo script."
  read -p "Pressione ENTER para retornar ao menu PINN..."; bash "$SCRIPT_DIR/menu_pinn.sh"; exit 1
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
  read -p "Pressione ENTER para retornar ao menu PINN..."; bash "$SCRIPT_DIR/menu_pinn.sh"; exit 0
fi

# Move a pasta para simulacoes/pinn
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
read -p "Pressione ENTER para retornar ao menu PINN..."
bash "$SCRIPT_DIR/menu_pinn.sh"; exit 0
