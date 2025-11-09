#!/bin/bash

# ─────────────────────────── Carrega env.sh (mínimo e idempotente) ─────────────
_AESC_LOADER_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
AESC_ROOT="$(cd "$_AESC_LOADER_DIR/../.." && pwd)"
for _aesc_env in "$AESC_ROOT/etc/env.sh" "$AESC_ROOT/src/env.sh" "$AESC_ROOT/env.sh"; do
  [ -f "$_aesc_env" ] && . "$_aesc_env" && break
done
unset _aesc_env _AESC_LOADER_DIR
# ────────────────────────────────────────────────────────────────────────────────

# Limpar uma pasta de simulação (Python Científico)
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# Caminhos via env.sh (com fallbacks)
AESC_ROOT="${AESC_ROOT:?AESC_ROOT não definido; verifique etc/env.sh}"
SIMS_BASE="${AESC_SIMS_DIR:-$AESC_ROOT/simulations}"
[[ -d "$AESC_ROOT/simulacoes" && ! -d "$SIMS_BASE" ]] && SIMS_BASE="$AESC_ROOT/simulacoes"
SIM_DIR="$SIMS_BASE/python"

clear
echo ""
echo "╔══════════════════════════════════════════════════════════════════════════════╗"
echo "║      🧪 AESC v1.0 | Ambiente de Execução de Simulações Científicas           ║"
echo "║              💻 Laboratório Pessoal de Computação Científica                 ║"
echo "║                Desenvolvido por Prof. Rafael Gabler Gontijo                  ║"
echo "╠══════════════════════════════════════════════════════════════════════════════╣"
echo "║               Ambiente – Python Científico 🐍 | Limpar simulação             ║"
echo "╚══════════════════════════════════════════════════════════════════════════════╝"
echo ""

if [[ ! -d "$SIM_DIR" ]]; then
  echo "❌ Diretório de simulações não encontrado: $SIM_DIR"
  read -r -p "ENTER para voltar..." _
  exec bash "$SCRIPT_DIR/menu_python.sh"
fi

cd "$SIM_DIR" || { echo "❌ Falha ao acessar $SIM_DIR"; read -r -p "ENTER..." _; exec bash "$SCRIPT_DIR/menu_python.sh"; }

mapfile -t PASTAS < <(find . -maxdepth 1 -mindepth 1 -type d ! -name ".*" -printf "%P\n" | sort)
if [[ ${#PASTAS[@]} -eq 0 ]]; then
  echo "⚠️ Nenhuma pasta de simulação encontrada em: $SIM_DIR"
  read -r -p "ENTER para voltar..." _
  exec bash "$SCRIPT_DIR/menu_python.sh"
fi

echo "🧹 Pastas disponíveis:"
for i in "${!PASTAS[@]}"; do echo " [$i] 📁 ${PASTAS[$i]}"; done
RET_IDX=${#PASTAS[@]}
echo " [$RET_IDX] 🔙 Voltar ao menu Python Científico"
echo ""
read -r -p "Digite o número da pasta que deseja limpar: " escolha

if [[ "$escolha" == "$RET_IDX" ]]; then
  exec bash "$SCRIPT_DIR/menu_python.sh"
fi
if ! [[ "$escolha" =~ ^[0-9]+$ ]] || (( escolha < 0 || escolha >= ${#PASTAS[@]} )); then
  echo "❌ Opção inválida."
  read -r -p "ENTER para voltar..." _
  exec bash "$SCRIPT_DIR/menu_python.sh"
fi

PASTA="${PASTAS[$escolha]}"
ABS_PATH="$SIM_DIR/$PASTA"
echo ""
echo "⚠️ Confirma limpar TODO o conteúdo de:"
echo "   $ABS_PATH"
read -r -p "Digite 'SIM' para confirmar: " conf
[[ "$conf" != "SIM" ]] && { echo "❌ Operação cancelada."; read -r -p "ENTER..." _; exec bash "$SCRIPT_DIR/menu_python.sh"; }

rm -r "$ABS_PATH"
echo ""
echo "✅ Limpeza concluída em: $ABS_PATH"
read -r -p "Pressione ENTER para retornar ao menu Python Científico..." _
exec bash "$SCRIPT_DIR/menu_python.sh"
